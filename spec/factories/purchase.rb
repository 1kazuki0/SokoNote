FactoryBot.define do
  factory :purchase do
    brand { "ブランド" }
    content_quantity { 3 }
    pack_quantity { 2 }
    price { 300 }
    tax_rate { 0 } # unit_priceでtax_rateを使用するので先に定義する
    unit_price { (price.to_f / (1 + tax_rate * 0.01)) / content_quantity / pack_quantity }
    purchased_on { "2026/01/01" }
    user
    item
    store
    content_unit
    pack_unit

    trait :only_required_purchase do
      brand { nil }
      store { nil }
      pack_unit { nil }
    end
  end
end
