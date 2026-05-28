class HouseholdPolicy < ApplicationPolicy
  # Any signed-in user can create or join a household
  def new?
    true
  end

  def create?
    true
  end

  # Only members can view/update/delete a household
  def show?
    record.members.include?(user)
  end

  def update?
    show?
  end

  def destroy?
    membership = record.memberships.find_by(user: user)
    membership&.admin?
  end
end
