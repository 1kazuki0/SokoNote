FactoryBot.define do
  factory :content_unit do
    sequence(:name) { |n| "単位（内容量）#{n}" }
    user
  end
end
