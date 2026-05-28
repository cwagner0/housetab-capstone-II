class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_household
  before_action :ensure_member

  def index
    @expenses = @household.expenses.recent.includes(:payer, :splits, :debtors)
  end

  def new
    @expense = @household.expenses.new(date: Date.current)
    @members = @household.members.where.not(id: current_user.id)
  end

  def create
    @expense = @household.expenses.new(expense_params)
    @expense.payer = current_user

    debtor_ids = Array(params[:expense][:debtor_ids]).reject(&:blank?).map(&:to_i)

    if debtor_ids.empty?
      @expense.errors.add(:base, "Pick at least one roommate to split with")
      @members = @household.members.where.not(id: current_user.id)
      render :new, status: :unprocessable_entity
      return
    end

    # Even split: floor to avoid going over total (payer eats remainder)
    per_person = (@expense.total_amount.to_d / (debtor_ids.size + 1)).floor(2)

    begin
      Expense.transaction do
        @expense.save!
        debtor_ids.each do |uid|
          @expense.splits.create!(user_id: uid, amount_owed: per_person)
        end
      end
      redirect_to [@household, @expense], notice: "Expense added."
    rescue ActiveRecord::RecordInvalid
      @members = @household.members.where.not(id: current_user.id)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @expense = @household.expenses.find(params[:id])
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

  def expense_params
    params.require(:expense).permit(:description, :total_amount, :store_name, :date, :notes, :receipt_photo)
  end
end
