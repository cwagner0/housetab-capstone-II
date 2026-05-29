# == Schema Information
#
# Table name: settlements
#
#  id           :bigint           not null, primary key
#  amount       :decimal(10, 2)   not null
#  confirmed_at :datetime
#  note         :string
#  status       :string           default("pending"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  from_user_id :bigint           not null
#  household_id :bigint           not null
#  to_user_id   :bigint           not null
#
# Indexes
#
#  index_settlements_on_from_user_id             (from_user_id)
#  index_settlements_on_household_id             (household_id)
#  index_settlements_on_household_id_and_status  (household_id,status)
#  index_settlements_on_to_user_id               (to_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (from_user_id => users.id)
#  fk_rails_...  (household_id => households.id)
#  fk_rails_...  (to_user_id => users.id)
#
class Settlement < ApplicationRecord
  # --- Associations ---
  belongs_to :household
  belongs_to :sender, class_name: "User", foreign_key: "from_user_id"
  belongs_to :recipient, class_name: "User", foreign_key: "to_user_id"

  # --- Validations ---
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending confirmed disputed] }
  validate :sender_and_recipient_are_different

  # --- Scopes ---
  scope :pending_status, -> { where(status: "pending") }
  scope :confirmed_status, -> { where(status: "confirmed") }
  scope :disputed_status, -> { where(status: "disputed") }
  scope :recent, -> { order(created_at: :desc) }

  # --- Methods ---
  def pending?
    status == "pending"
  end

  def confirmed?
    status == "confirmed"
  end

  def disputed?
    status == "disputed"
  end

  def confirm!
    update!(status: "confirmed", confirmed_at: Time.current)
  end

  def dispute!
    update!(status: "disputed")
  end

  def confirmable_by?(user)
    pending? && user == recipient
  end

  private

  def sender_and_recipient_are_different
    if from_user_id == to_user_id
      errors.add(:base, "You can't settle up with yourself")
    end
  end
end
