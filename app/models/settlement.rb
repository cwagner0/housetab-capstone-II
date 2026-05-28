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
