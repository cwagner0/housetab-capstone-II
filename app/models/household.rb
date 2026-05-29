# == Schema Information
#
# Table name: households
#
#  id          :bigint           not null, primary key
#  invite_code :string           not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_households_on_invite_code  (invite_code) UNIQUE
#
class Household < ApplicationRecord
  # --- Associations ---
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :expenses, dependent: :destroy
  has_many :settlements, dependent: :destroy

  # --- Validations ---
  validates :name, presence: true
  validates :invite_code, presence: true, uniqueness: true

  # --- Callbacks ---
  before_validation :generate_invite_code, on: :create

  # --- Methods ---
  def total_spent
    expenses.sum(:total_amount)
  end

  def expense_count
    expenses.count
  end

  def settlement_count
    settlements.where(status: "confirmed").count
  end

  def admin
    memberships.find_by(role: "admin")&.user
  end

  private

  def generate_invite_code
    return if invite_code.present?

    loop do
      self.invite_code = "#{name.first(4).upcase.gsub(/[^A-Z0-9]/, 'X')}-#{SecureRandom.alphanumeric(4).upcase}"
      break unless Household.exists?(invite_code: invite_code)
    end
  end
end
