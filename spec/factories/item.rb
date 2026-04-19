FactoryBot.define do
  factory :item do
    sequence(:name) { |n| "商品#{n}" }
    user
    category

    trait :not_category_item do
      category { nil }
    end
  end
end
