class ExpensePolicy < ApplicationPolicy
  def show?
    member_of_household?
  end

  def create?
    member_of_household?
  end

  def update?
    member_of_household? && record.payer == user
  end

  def destroy?
    update?
  end

  private

  def member_of_household?
    record.household.members.include?(user)
  end
end
