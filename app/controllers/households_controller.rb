class HouseholdsController < ApplicationController
  before_action :authenticate_user!

  def new
    @household = Household.new
    authorize! @household
  end

  def create
    @household = Household.new(household_params)
    authorize! @household
    if @household.save
      Membership.create!(user: current_user, household: @household, role: "admin")
      redirect_to @household, notice: "Household created. Invite code: #{@household.invite_code}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @household = Household.find(params[:id])
    authorize! @household
    @memberships = @household.memberships.includes(:user)
    @recent_expenses = @household.expenses.recent.limit(10)
  end

  def join_form
    # GET /households/join — anyone signed in can see the form
  end

  def join
    code = params[:invite_code].to_s.strip.upcase
    household = Household.find_by(invite_code: code)

    if household.nil?
      redirect_to join_household_path, alert: "Invalid invite code."
      return
    end

    if household.members.include?(current_user)
      redirect_to household, notice: "You're already a member of #{household.name}."
      return
    end

    Membership.create!(user: current_user, household: household, role: "member")
    redirect_to household, notice: "Joined #{household.name}!"
  end

  private

  def household_params
    params.require(:household).permit(:name)
  end
end
