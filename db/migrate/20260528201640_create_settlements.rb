class CreateSettlements < ActiveRecord::Migration[8.0]
  def change
    create_table :settlements do |t|
      t.references :household, null: false, foreign_key: true
      t.references :from_user, null: false, foreign_key: { to_table: :users }
      t.references :to_user, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.string :note
      t.string :status, null: false, default: "pending"
      t.datetime :confirmed_at

      t.timestamps
    end

    add_index :settlements, [:household_id, :status]
  end
end
