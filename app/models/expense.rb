class Expense < ApplicationRecord
  # --- Associations ---
  belongs_to :household
  belongs_to :payer, class_name: "User", foreign_key: "paid_by_user_id"
  has_many :splits, dependent: :destroy
  has_many :debtors, through: :splits, source: :user

  # Receipt photo (ActiveStorage)
  has_one_attached :receipt_photo

  # --- Live updates ---
  broadcasts_refreshes
  after_commit -> { household.broadcast_refresh_later }, on: [:create, :update, :destroy]

  # --- Validations ---
  validates :description, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true

  validate :splits_dont_exceed_total

  # --- Scopes ---
  scope :recent, -> { order(date: :desc, created_at: :desc) }
  scope :for_month, ->(date) { where(date: date.beginning_of_month..date.end_of_month) }

  # --- Methods ---
  def split_count
    splits.count + 1
  end

  def category
    desc = description.downcase
    if desc.match?(/grocery|trader|costco|walmart|aldi|kroger|safeway|whole foods/)
      "grocery"
    elsif desc.match?(/restaurant|takeout|pizza|thai|chinese|sushi|uber eats|doordash/)
      "restaurant"
    elsif desc.match?(/clean|paper|soap|trash|toilet|household|amazon/)
      "household"
    else
      "other"
    end
  end

  private

  def splits_dont_exceed_total
    return unless total_amount.present? && splits.any?

    splits_total = splits.sum(&:amount_owed)
    if splits_total > total_amount
      errors.add(:base, "Split amounts ($#{splits_total}) exceed the total ($#{total_amount})")
    end
  end
end
