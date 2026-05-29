class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_household

  def index
    authorize! @household, to: :show?
    @expenses = @household.expenses.recent.includes(:payer, :splits, :debtors)
  end

  def new
    authorize! @household, to: :show?
    @expense = @household.expenses.new(date: Date.current)
    @members = @household.members.where.not(id: current_user.id)
  end

  def create
    @expense = @household.expenses.new(expense_params)
    @expense.payer = current_user
    @expense.payer_included_in_split = (params.dig(:expense, :include_payer) == "1")
    authorize! @expense

    debtor_ids = Array(params[:expense][:debtor_ids]).reject(&:blank?).map(&:to_i)

    if debtor_ids.empty?
      @expense.errors.add(:base, "Pick at least one roommate to split with")
      @members = @household.members.where.not(id: current_user.id)
      render :new, status: :unprocessable_entity
      return
    end

    divisor = debtor_ids.size + (@expense.payer_included_in_split ? 1 : 0)
    per_person = (@expense.total_amount.to_d / divisor).floor(2)

    begin
      Expense.transaction do
        @expense.save!
        debtor_ids.each do |uid|
          @expense.splits.create!(user_id: uid, amount_owed: per_person)
        end
      end

      if @expense.receipt_photo.attached?
        ReceiptScanJob.perform_later(@expense.id)
        notice = "Expense added. AI is scanning the receipt..."
      else
        notice = "Expense added."
      end

      redirect_to [@household, @expense], notice: notice
    rescue ActiveRecord::RecordInvalid
      @members = @household.members.where.not(id: current_user.id)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @expense = @household.expenses.find(params[:id])
    authorize! @expense
  end

  def edit
    @expense = @household.expenses.find(params[:id])
    authorize! @expense, to: :update?
  end

  def update
    @expense = @household.expenses.find(params[:id])
    authorize! @expense, to: :update?

    old_total = @expense.total_amount

    if @expense.update(expense_params)
      if @expense.total_amount != old_total && @expense.splits.any?
        divisor = @expense.splits.count + (@expense.payer_included_in_split ? 1 : 0)
        per_person = (@expense.total_amount.to_d / divisor).floor(2)
        @expense.splits.update_all(amount_owed: per_person)
      end

      redirect_to [@household, @expense], notice: "Expense updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_household
    @household = Household.find(params[:household_id])
  end

  def expense_params
    params.require(:expense).permit(:description, :total_amount, :store_name, :date, :notes, :receipt_photo)
  end
end
