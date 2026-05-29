class ReceiptScanJob < ApplicationJob
  queue_as :default

  def perform(expense_id)
    expense = Expense.find(expense_id)
    return unless expense.receipt_photo.attached?

    data = ReceiptScanner.call(expense.receipt_photo.blob)

    Rails.logger.info "ReceiptScanJob parsed data for expense #{expense_id}: #{data.inspect}"

    expense.update!(
      store_name: data["store_name"].presence || expense.store_name,
      description: data["description"].presence || expense.description,
      total_amount: parsed_amount(data["total_amount"]) || expense.total_amount,
      date: parsed_date(data["date"]) || expense.date
    )

    if data["total_amount"].present? && expense.splits.any?
      divisor = expense.splits.count + (expense.payer_included_in_split ? 1 : 0)
      per_person = (expense.total_amount.to_d / divisor).floor(2)
      expense.splits.update_all(amount_owed: per_person)
    end

    Rails.logger.info "ReceiptScanJob completed for expense #{expense_id}"
  rescue => e
    Rails.logger.error "ReceiptScanJob FAILED for expense #{expense_id}: #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    raise
  end

  private

  def parsed_amount(raw)
    return nil if raw.nil?
    cleaned = raw.to_s.gsub(/[^0-9.\-]/, "")
    return nil if cleaned.empty?
    Float(cleaned)
  rescue ArgumentError, TypeError
    nil
  end

  def parsed_date(raw)
    Date.parse(raw.to_s)
  rescue Date::Error, TypeError
    nil
  end
end
