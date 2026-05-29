class AddPayerIncludedToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_column :expenses, :payer_included_in_split, :boolean, default: true, null: false
  end
end
