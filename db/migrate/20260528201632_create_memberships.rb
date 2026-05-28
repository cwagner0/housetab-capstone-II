class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :household, null: false, foreign_key: true
      t.string :role, null: false, default: "member"
      t.string :nickname

      t.timestamps
    end

    add_index :memberships, [:user_id, :household_id], unique: true
  end
end
