class Split < ApplicationRecord
  # --- Associations ---
  belongs_to :expense
  belongs_to :user

  # --- Validations ---
  validates :amount_owed, presence: true, numericality: { greater_than: 0 }
  validates :user_id, uniqueness: { scope: :expense_id, message: "already has a split on this expense" }

  # --- Convenience ---
  def payer
    expense.payer
  end

  def household
    expense.household
  end
end
