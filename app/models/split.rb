# == Schema Information
#
# Table name: splits
#
#  id          :bigint           not null, primary key
#  amount_owed :decimal(10, 2)   not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  expense_id  :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_splits_on_expense_id              (expense_id)
#  index_splits_on_expense_id_and_user_id  (expense_id,user_id) UNIQUE
#  index_splits_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (expense_id => expenses.id)
#  fk_rails_...  (user_id => users.id)
#
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
