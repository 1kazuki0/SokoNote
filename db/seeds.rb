# # 使用しない時は# #（2個）いれておく
# # 実行時はdocker compose exec web rails db:seedで実行



# # === ユーザーの生成（10件） ===
#     10.times do
#       User.create(name: Faker::Name.first_name,
#                   email: Faker::Internet.unique.email,
#                   password: "password")
#     end




# # === カテゴリの生成（10件） ===
#     # --- 1. User(34)を取得 ---
#     user = User.find(34)
#     # --- 2.カテゴリの配列を定義 ---
#     categories_list =["精肉", "鮮魚", "野菜", "果物", "乳製品", "卵・豆腐・納豆", "練り物・水産加工品", "精肉加工品（ハム・ソーセージ）", "漬物・佃煮", "麺類（生・ゆで）", "惣菜・お弁当","米・穀類", "麺類（乾麺）", "パン", "シリアル", "粉類（小麦粉・片栗粉）", "砂糖・甘味料", "塩・胡椒", "醤油・味噌", "酢・みりん・料理酒", "食用油", "ドレッシング・マヨネーズ", "ケチャップ・ソース", "だし・つゆ・スープの素", "香辛料・スパイス", "製菓材料", "乾物（海苔・わかめ）","レトルト食品", "カップ麺・袋麺", "缶詰・瓶詰", "冷凍食品（おかず）", "冷凍食品（米・麺）", "冷凍食品（野菜・フルーツ）", "フリーズドライ食品","スナック菓子", "チョコ・クッキー", "せんべい・和菓子", "飴・ガム・グミ", "デザート（ゼリー・プリン）", "アイスクリーム", "ケーキ・洋菓子","水・ミネラルウォーター", "お茶・ほうじ茶", "緑茶・抹茶", "紅茶・ハーブティー", "コーヒー（豆・粉）", "インスタントコーヒー", "炭酸飲料", "果汁・野菜ジュース", "スポーツドリンク", "乳飲料", "ビール・発泡酒", "ワイン・シャンパン", "焼酎・日本酒", "ウイスキー・ブランデー", "チューハイ・カクテル", "ノンアルコール飲料","食器用洗剤", "洗濯用洗剤", "柔軟剤・おしゃれ着洗剤", "住居用洗剤（風呂・トイレ）", "漂白剤・除菌剤", "キッチン消耗品（ラップ・ホイル）", "キッチン雑貨（スポンジ・布巾）", "ゴミ袋・ポリ袋", "掃除用品（シート・ブラシ）","シャンプー・リンス", "ボディソープ・石鹸", "入浴剤", "洗顔・スキンケア", "ヘアケア・スタイリング剤", "オーラルケア（歯ブラシ・歯磨き粉）", "カミソリ・シェービング", "ハンドソープ・手指消毒","トイレットペーパー", "ティッシュペーパー", "ウェットティッシュ", "生理用品", "おむつ（ベビー）", "おむつ（大人用）", "マスク・衛生用品", "救急用品（絆創膏・消毒液）","衣類用防虫剤・消臭剤", "芳香剤・消臭剤（部屋・トイレ）", "電池・電球", "文房具・事務用品", "ペットフード（犬）", "ペットフード（猫）", "ペット用品（衛生）", "ガーデニング・園芸用品", "カー用品", "衣類・靴下", "キッチン用品・調理器具", "季節用品（カイロ・保冷剤）"]
#     failed = []
#     # --- 3.100回繰り返す ---
#     100.times do
#       selected_category_name = categories_list.sample
#       category = Category.new(user: user,
#                                   name: selected_category_name)
#       if category.save
#       else
#         failed << { data: category, errors: category.errors.full_messages }
#       end
#     end

#     if failed.any?
#       puts "=== 失敗したレコード: #{failed.size}件 ==="
#       failed.each do |f|
#         puts "#{f[:data].name} → #{f[:errors]}"
#       end
#     else
#       puts "=== 全件保存成功 ==="
#     end



# # === 商品の生成（10件） ===
#     # --- 1. User(34), カテゴリ(4)を取得 ---
#     user = User.find(34)
#     category = Category.find(24)
#     failed = []
#     # --- 2. Itemのレコード生成 ---
#     100.times do
#       item = Item.new(user: user,
#                       category: category,
#                       name: Faker::Food.vegetables) # uniqueで今まで出したデータと被らないようにする。
#       if item.save
#       else
#         failed << { data: item, errors: item.errors.full_messages }
#       end
#     end

#     if failed.any?
#       puts "=== 失敗したレコード: #{failed.size}件 ==="
#       failed.each do |f|
#         puts "#{f[:data].name} → #{f[:errors]}"
#       end
#     else
#       puts "=== 全件保存成功 ==="
#     end



# # === 店舗の生成 ===
#     # --- 1. User(34)を取得 ---
#     user = User.find(34)
#     failed = []
#     100.times do
#       store = Store.new(user: user,
#                         name: Faker::Company.name)
#       if store.save
#       else
#         failed << { data: store, errors: store.errors.full_messages }
#       end
#     end

#     if failed.any?
#       puts "=== 失敗したレコード: #{failed.size}件 ==="
#       failed.each do |f|
#         puts "#{f[:data].name} → #{f[:errors]}"
#       end
#     else
#       puts "=== 全件保存成功 ==="
#     end




# # === 購入履歴の生成（10件） ===
#     failed = []
#     user = User.find(34)

#     1000.times do
#       # --- 1. User(34), Item(24), Store(1..5)を取得  また外に出す---
#       item = Item.where(user_id: user.id).order("RANDOM()").first
#       store = Store.where(user_id: user.id).order("RANDOM()").first
#       # --- 2. p_price(価格), c_qty(内容量), p_qty（パック数), tax_rate(消費税)を一時取得 ---
#       p_price = Faker::Number.within(range: 1..10000)
#       c_qty   = Faker::Number.within(range: 1..1000)
#       p_qty   = Faker::Number.within(range: 1..10)
#       tax_rate = [ 0, 8, 10 ].sample
#       content_unit = ["g","kg","mg","ml","l","個","本","枚","袋","箱","粒","錠","缶","パック","切れ","玉","束","杯","食","皿"].sample
#       pack_unit = ["個入り","本入り","枚入り","袋入り","箱入り","パック入り","セット","束","ケース","ロール","袋","箱","パック","ボトル","缶","袋セット","箱セット","パックセット","まとめ","アソート"].sample
#       # --- 3. priceが税込の場合、税抜金額にして統一 ---
#       tax_multiplier = 1 + (tax_rate.to_f / 100)
#       price_without_tax = p_price / tax_multiplier
#       # --- 4. 税抜金額から内容量とパック数を割り単価を算定 ---
#       calc_unit_price = (price_without_tax / (c_qty * p_qty)).round(2)
#       # --- 5. Purchaseのレコード生成 ---
#       purchase = Purchase.new(user: user,
#                     item: item,
#                     store: store,
#                     brand: Faker::Company.name,
#                     content_quantity: c_qty,
#                     content_unit: content_unit,
#                     pack_quantity: p_qty,
#                     pack_unit: pack_unit,
#                     price: p_price,
#                     tax_rate: tax_rate,
#                     unit_price: calc_unit_price,
#                     purchased_on: Faker::Date.between(from: '2020-01-01', to: '2025-12-31')
#       )
#       if purchase.save
#       else
#         failed << { data: purchase, errors: purchase.errors.full_messages }
#       end
#     end

#       if failed.any?
#         puts "=== 失敗したレコード: #{failed.size}件 ==="
#         failed.each do |f|
#           p = f[:data]
#           puts "----- 失敗データ -----"
#           puts "item: #{p.item&.name}"
#           puts "price: #{p.price}"
#           puts "content_quantity: #{p.content_quantity}"
#           puts "pack_quantity: #{p.pack_quantity}"
#           puts "unit_price: #{p.unit_price}"
#           puts "errors: #{f[:errors]}"
#         end
#       else
#         puts "=== 全件保存成功 ==="
#     end

# === デモユーザーの作成 ===
demo_email = ENV.fetch("DEMO_USER_EMAIL")
demo_password = ENV.fetch("DEMO_USER_PASSWORD")
demo_user_name = ENV.fetch("DEMO_USER_NAME")

demo_user = User.find_or_initialize_by(email: demo_email)
demo_user.assign_attributes(name: demo_user_name, password: demo_password, password_confirmation: demo_password)
demo_user.save!

puts "デモユーザーを作成しました: #{demo_user.email}"