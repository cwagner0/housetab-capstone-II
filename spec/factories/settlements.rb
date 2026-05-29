FactoryBot.define do
  factory :settlement do
    household
    association :sender, factory: :user
    association :recipient, factory: :user
    amount { 10.00 }
    status { "pending" }
  end
end
