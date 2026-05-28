class MembershipPolicy < ApplicationPolicy
  # Only admins can remove other members; nobody can remove themselves via this path
  def destroy?
    return false if record.user == user

    admin_membership = record.household.memberships.find_by(user: user)
    admin_membership&.admin?
  end
end
