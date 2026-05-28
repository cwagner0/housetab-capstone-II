class SettlementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_household, except: [:confirm, :dispute]
  before_action :ensure_member, except: [:confirm, :dispute]

  def index
    @settlements = @household.settlements.recent.includes(:sender, :recipient)
  end

  def new
    @settlement = @household.settlements.new(
      sender: current_user,
      to_user_id: params[:to_user_id]
    )
    @recipients = @household.members.where.not(id: current_user.id)
  end

  def create
    @settlement = @household.settlements.new(settlement_params)
    @settlement.sender = current_user
    @settlement.status ||= "pending"

    if @settlement.save
      redirect_to household_settlements_path(@household),
                  notice: "Settlement logged. Awaiting #{@settlement.recipient.name}'s confirmation."
    else
      @recipients = @household.members.where.not(id: current_user.id)
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @settlement = Settlement.find(params[:id])
    if @settlement.confirmable_by?(current_user)
      @settlement.confirm!
      redirect_to household_settlements_path(@settlement.household), notice: "Confirmed."
    else
      redirect_to household_settlements_path(@settlement.household), alert: "You can't confirm that settlement."
    end
  end

  def dispute
    @settlement = Settlement.find(params[:id])
    if @settlement.confirmable_by?(current_user)
      @settlement.dispute!
      redirect_to household_settlements_path(@settlement.household), notice: "Disputed."
    else
      redirect_to household_settlements_path(@settlement.household), alert: "You can't dispute that settlement."
    end
  end

  private

  def set_household
    @household = Household.find(params[:household_id])
  end

  def ensure_member
    unless @household.members.include?(current_user)
      redirect_to root_path, alert: "You're not a member of that household."
    end
  end

  def settlement_params
    params.require(:settlement).permit(:to_user_id, :amount, :note)
  end
end
