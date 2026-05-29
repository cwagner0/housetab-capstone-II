class ReceiptScanJob < ApplicationJob
  queue_as :default

  def perform(expense_id)
    expense = Expense.find(expense_id)
    return unless expense.receipt_photo.attached?

    data = ReceiptScanner.call(expense.receipt_photo.blob)

    # Update expense with extracted data (fall back to existing values if AI returns blanks)
    expense.update!(
      store_name: data["store_name"].presence || expense.store_name,
      description: data["description"].presence || expense.description,
      total_amount: parsed_amount(data["total_amount"]) || expense.total_amount,
      date: parsed_date(data["date"]) || expense.date
    )

    # If total changed, recalculate splits evenly
    if data["total_amount"].present? && expense.splits.any?
      n = expense.splits.count + 1  # +1 for the payer
      per_person = (expense.total_amount.to_d / n).floor(2)
      expense.splits.update_all(amount_owed: per_person)
    end

    Rails.logger.info "ReceiptScanJob completed for expense #{expense_id}"
  rescue => e
    Rails.logger.error "ReceiptScanJob failed for expense #{expense_id}: #{e.class}: #{e.message}"
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
