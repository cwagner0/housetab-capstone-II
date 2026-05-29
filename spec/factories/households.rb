FactoryBot.define do
  factory :household do
    sequence(:name) { |n| "House #{n}" }
  end
end
