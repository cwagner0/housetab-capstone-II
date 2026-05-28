class SettlementPolicy < ApplicationPolicy
  def show?
    record.household.members.include?(user)
  end

  def create?
    show?
  end

  # Only the recipient of a pending settlement can confirm or dispute it
  def confirm?
    record.pending? && user == record.recipient
  end

  def dispute?
    confirm?
  end
end
