FactoryBot.define do
  factory :membership do
    user
    household
    role { "member" }
  end
end
