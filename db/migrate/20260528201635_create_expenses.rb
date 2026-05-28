class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.references :household, null: false, foreign_key: true
      t.references :paid_by_user, null: false, foreign_key: { to_table: :users }
      t.string :description, null: false
      t.decimal :total_amount, null: false, precision: 10, scale: 2
      t.string :store_name
      t.date :date, null: false
      t.text :notes

      t.timestamps
    end

    add_index :expenses, [:household_id, :date]
  end
end
