FactoryBot.define do
  factory :split do
    expense
    user
    amount_owed { 10.00 }
  end
end
