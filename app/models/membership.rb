# == Schema Information
#
# Table name: memberships
#
#  id           :bigint           not null, primary key
#  nickname     :string
#  role         :string           default("member"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  household_id :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_memberships_on_household_id              (household_id)
#  index_memberships_on_user_id                   (user_id)
#  index_memberships_on_user_id_and_household_id  (user_id,household_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (household_id => households.id)
#  fk_rails_...  (user_id => users.id)
#
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
