FactoryBot.define do
  factory :expense do
    household
    association :payer, factory: :user
    description { "Groceries" }
    total_amount { 30.00 }
    date { Date.current }
    payer_included_in_split { true }
  end
end
