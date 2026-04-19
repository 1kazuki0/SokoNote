FactoryBot.define do
  factory :content_unit do
    sequence(:name) { |n| "内容量単位#{n}" }
    user
  end
end
