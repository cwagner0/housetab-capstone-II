class Membership < ApplicationRecord
  # --- Associations ---
  belongs_to :user
  belongs_to :household

  # --- Validations ---
  validates :role, presence: true, inclusion: { in: %w[admin member] }
  validates :user_id, uniqueness: { scope: :household_id, message: "is already a member of this household" }

  # --- Methods ---
  def admin?
    role == "admin"
  end

  def display_name
    nickname.presence || user.name
  end
end
