FactoryBot.define do
  factory :pack_unit do
    sequence(:name) { |n| "包装単位#{n}" }
    user
  end
end
