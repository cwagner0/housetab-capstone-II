class BalancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_household

  def show
    authorize! @household, to: :show?
    @other_user = @household.members.find(params[:user_id])
    @net_balance = current_user.net_balance_with(@other_user, @household)

    @expenses_i_paid = @household.expenses
      .where(paid_by_user_id: current_user.id)
      .joins(:splits).where(splits: { user_id: @other_user.id })
      .distinct.includes(:splits).recent

    @expenses_they_paid = @household.expenses
      .where(paid_by_user_id: @other_user.id)
      .joins(:splits).where(splits: { user_id: current_user.id })
      .distinct.includes(:splits).recent

    @settlements = Settlement.where(household: @household)
      .where(
        "(from_user_id = ? AND to_user_id = ?) OR (from_user_id = ? AND to_user_id = ?)",
        current_user.id, @other_user.id, @other_user.id, current_user.id
      )
      .order(created_at: :desc)
  end

  private

  def set_household
    @household = Household.find(params[:household_id])
  end
end
