class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @memberships = current_user.memberships.includes(:household)
    @current_household = @memberships.first&.household

    if @current_household
      @balances = @user.all_balances_in(@current_household)
      @recent_expenses = @current_household.expenses.recent.limit(5)
    end
  end
end
