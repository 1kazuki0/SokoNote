# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 10.times do
#   User.create(name: Faker::Name.first_name,
#               email: Faker::Internet.unique.email,
#               password: "password")
# end
# Foodの自動再生
  # user_id:22 category_id:4を固定し代入
  # user = User.find(22)
  # category = Category.find(4)
  # # 10回繰り返し
  # 10.times do
  #   Item.create(user: user,
  #               category: category,
  #               name: Faker::Food.unique.vegetables) # uniqueで今まで出したデータと被らないようにする。
  # end
  # docker compose exec web rails db:seedで実行すると10件分のItemが生成される

# 購入履歴の自動再生
  # user_id, item_id, category_idは全てidを1で固定
  # storeはid[1, 2, 3, 4, 5をランダム抽出
  10.times do
    user = User.find(1)
    item = Item.find(1)
    store = Store.where(id: 1..5).sample
    p_price = Faker::Number.within(range: 100..1500)
    c_qty   = [500, 1000, 1500].sample
    p_qty   = [1, 2, 3].sample
    tax_rate = [0, 8, 10].sample
    price_with_tax = p_price * (1 + tax_rate.to_f / 100)
    calc_unit_price = (price_with_tax / (c_qty * p_qty)).round(2)
    Purchase.create!(user: user,
                    item: item, 
                    store: store,
                    brand: Faker::Company.name,                                             # ブランド名
                    content_quantity: c_qty,                             # 内容量
                    content_unit: "ml",                                                     # 内容量単位
                    pack_quantity: p_qty,                                        # パック数
                    pack_unit: "本",                                                        # パック単位
                    price: p_price,                         # 価格
                    tax_rate: tax_rate,                                            # 消費税
                    unit_price: calc_unit_price,                              # 計算後の単価
                    purchased_on: Faker::Date.between(from: '2025-01-01', to: '2025-12-31') # 購入日
    )
end
