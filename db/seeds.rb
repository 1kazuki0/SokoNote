    # 使用しない時は# #（2個）いれておく
    # 実行時はdocker compose exec web rails db:seedで実行

    # === ユーザーの生成（10件） ===
    10.times do
      User.create(name: Faker::Name.first_name,
                  email: Faker::Internet.unique.email,
                  password: "password")
      end

    # === 商品の生成（10件） ===
    # --- 1. User(22), カテゴリ(4)を取得 ---
    user = User.find(22)
    category = Category.find(4)
    # --- 2. Itemのレコード生成 ---
    10.times do
      Item.create(user: user,
                  category: category,
                  name: Faker::Food.unique.vegetables) # uniqueで今まで出したデータと被らないようにする。
    end

    # === 購入履歴の生成（10件） ===
    10.times do
      # --- 1. User(1), Item(1), Store(1..5)を取得  また外に出す---
      user = User.find(1)
      item = Item.find(1)
      store = Store.where(id: 1..5).sample
      # --- 2. p_price(価格), c_qty(内容量), p_qty（パック数), tax_rate(消費税)を一時取得 ---
      p_price = Faker::Number.within(range: 100..1500)
      c_qty   = [ 500, 1000, 1500 ].sample
      p_qty   = [ 1, 2, 3 ].sample
      tax_rate = [ 0, 8, 10 ].sample
      # --- 3. priceが税込の場合、税抜金額にして統一 ---
      tax_multiplier = 1 + (tax_rate.to_f / 100)
      price_without_tax = p_price / tax_multiplier
      # --- 4. 税抜金額から内容量とパック数を割り単価を算定 ---
      calc_unit_price = (price_without_tax / (c_qty * p_qty)).round(2)
      # --- 5. Purchaseのレコード生成 ---
      Purchase.create!(user: user,
                    item: item,
                    store: store,
                    brand: Faker::Company.name,
                    content_quantity: c_qty,
                    content_unit: "ml",
                    pack_quantity: p_qty,
                    pack_unit: "本",
                    price: p_price,
                    tax_rate: tax_rate,
                    unit_price: calc_unit_price,
                    purchased_on: Faker::Date.between(from: '2025-01-01', to: '2025-12-31')
    )
    end
