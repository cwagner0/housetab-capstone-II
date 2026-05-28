class SettlementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_household, except: [:confirm, :dispute]

  def index
    authorize! @household, to: :show?
    @settlements = @household.settlements.recent.includes(:sender, :recipient)
  end

  def new
    authorize! @household, to: :show?
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
    authorize! @settlement

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
    authorize! @settlement, to: :confirm?
    @settlement.confirm!
    redirect_to household_settlements_path(@settlement.household), notice: "Confirmed."
  end

  def dispute
    @settlement = Settlement.find(params[:id])
    authorize! @settlement, to: :dispute?
    @settlement.dispute!
    redirect_to household_settlements_path(@settlement.household), notice: "Disputed."
  end

  private

  def set_household
    @household = Household.find(params[:household_id])
  end

  def settlement_params
    params.require(:settlement).permit(:to_user_id, :amount, :note)
  end
end
