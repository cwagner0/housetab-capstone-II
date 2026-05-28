class User < ApplicationRecord
  # Devise authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # --- Associations ---
  has_many :memberships, dependent: :destroy
  has_many :households, through: :memberships

  has_many :paid_expenses, class_name: "Expense", foreign_key: "paid_by_user_id", dependent: :destroy
  has_many :splits, dependent: :destroy

  has_many :sent_settlements, class_name: "Settlement", foreign_key: "from_user_id", dependent: :destroy
  has_many :received_settlements, class_name: "Settlement", foreign_key: "to_user_id", dependent: :destroy

  # --- Validations ---
  validates :name, presence: true

  # --- Methods ---
  # Net balance with another user in a specific household.
  # Positive = they owe you. Negative = you owe them.
  def net_balance_with(other_user, household)
    they_owe_me = Split.joins(:expense)
      .where(user: other_user)
      .where(expenses: { paid_by_user_id: self.id, household_id: household.id })
      .sum(:amount_owed)

    i_owe_them = Split.joins(:expense)
      .where(user: self)
      .where(expenses: { paid_by_user_id: other_user.id, household_id: household.id })
      .sum(:amount_owed)

    they_settled = Settlement.where(
      sender: other_user, recipient: self,
      household: household, status: "confirmed"
    ).sum(:amount)

    i_settled = Settlement.where(
      sender: self, recipient: other_user,
      household: household, status: "confirmed"
    ).sum(:amount)

    (they_owe_me - they_settled) - (i_owe_them - i_settled)
  end

  def all_balances_in(household)
    household.members.where.not(id: self.id).map do |other|
      {
        user: other,
        amount: net_balance_with(other, household)
      }
    end
  end

  def total_owed_to_you(household)
    all_balances_in(household)
      .select { |b| b[:amount] > 0 }
      .sum { |b| b[:amount] }
  end

  def initial
    name.first.upcase
  end
end
