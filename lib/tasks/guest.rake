namespace :demo do
  desc "デモユーザーのデータをリセット（24時）"
  task reset: :environment do
    demo = User.find_by(email: "demo@example.com")
    unless demo
      puts "デモユーザーが見つかりません"
      next
    end

    ActiveRecord::Base.transaction do
      # 既存データを削除
      demo.purchases.destroy_all
      demo.items.destroy_all
      demo.categories.destroy_all
      demo.stores.destroy_all
      demo.content_units.destroy_all
      demo.pack_units.destroy_all

      # カテゴリ
      categories = {}
      %w[飲料 日用品 お肉 野菜 調味料 お菓子].each do |name|
        categories[name] = demo.categories.create!(name: name)
      end

      # 店舗
      stores = {}
      %w[イオン 業務スーパー マツモトキヨシ セブンイレブン].each do |name|
        stores[name] = demo.stores.create!(name: name)
      end

      # 内容量単位
      content_units = {}
      %w[ml g 枚 個 ロール].each do |name|
        content_units[name] = demo.content_units.create!(name: name)
      end

      # 包装単位
      pack_units = {}
      %w[本 箱 袋 パック].each do |name|
        pack_units[name] = demo.pack_units.create!(name: name)
      end

      # 商品
      items_data = [
        { name: "緑茶",               category: "飲料" },
        { name: "牛乳",               category: "飲料" },
        { name: "ティッシュ",         category: "日用品" },
        { name: "トイレットペーパー", category: "日用品" },
        { name: "豚こま肉",           category: "お肉" },
        { name: "鶏むね肉",           category: "お肉" },
        { name: "キャベツ",           category: "野菜" },
        { name: "醤油",               category: "調味料" },
        { name: "ポテトチップス",     category: "お菓子" },
        { name: "チョコレート",       category: "お菓子" }
      ]

      items = {}
      items_data.each do |data|
        items[data[:name]] = demo.items.create!(
          name: data[:name],
          category: categories[data[:category]]
        )
      end

      # 購入履歴(底値比較が映えるよう、同じItemを複数店舗で)
      purchases_data = [
        # 緑茶:500ml×1本を3店舗で
        { item: "緑茶", store: "イオン",         brand: "伊藤園",     content_quantity: 500, content_unit: "ml", pack_quantity: 1, pack_unit: "本", price: 128, tax_rate: 8, days_ago: 1 },
        { item: "緑茶", store: "業務スーパー",   brand: "伊藤園",     content_quantity: 500, content_unit: "ml", pack_quantity: 1, pack_unit: "本", price: 98,  tax_rate: 8, days_ago: 5 },
        { item: "緑茶", store: "セブンイレブン", brand: "伊藤園",     content_quantity: 500, content_unit: "ml", pack_quantity: 1, pack_unit: "本", price: 151, tax_rate: 8, days_ago: 10 },

        # 牛乳:1000ml×1本
        { item: "牛乳", store: "イオン",         brand: "明治",       content_quantity: 1000, content_unit: "ml", pack_quantity: 1, pack_unit: "本", price: 258, tax_rate: 8, days_ago: 2 },
        { item: "牛乳", store: "業務スーパー",   brand: "明治",       content_quantity: 1000, content_unit: "ml", pack_quantity: 1, pack_unit: "本", price: 218, tax_rate: 8, days_ago: 8 },

        # ティッシュ:200枚×5箱
        { item: "ティッシュ", store: "マツモトキヨシ", brand: "エリエール", content_quantity: 200, content_unit: "枚", pack_quantity: 5, pack_unit: "箱", price: 398, tax_rate: 10, days_ago: 3 },
        { item: "ティッシュ", store: "イオン",         brand: "エリエール", content_quantity: 200, content_unit: "枚", pack_quantity: 5, pack_unit: "箱", price: 448, tax_rate: 10, days_ago: 12 },

        # トイレットペーパー:12ロール×1袋
        { item: "トイレットペーパー", store: "マツモトキヨシ", brand: "スコッティ", content_quantity: 12, content_unit: "ロール", pack_quantity: 1, pack_unit: "袋", price: 498, tax_rate: 10, days_ago: 4 },
        { item: "トイレットペーパー", store: "業務スーパー",   brand: "スコッティ", content_quantity: 12, content_unit: "ロール", pack_quantity: 1, pack_unit: "袋", price: 428, tax_rate: 10, days_ago: 11 },

        # 豚こま肉:300g
        { item: "豚こま肉", store: "イオン",       brand: nil, content_quantity: 300, content_unit: "g", pack_quantity: 1, pack_unit: "パック", price: 498, tax_rate: 8, days_ago: 1 },
        { item: "豚こま肉", store: "業務スーパー", brand: nil, content_quantity: 300, content_unit: "g", pack_quantity: 1, pack_unit: "パック", price: 398, tax_rate: 8, days_ago: 7 },

        # 鶏むね肉:500g
        { item: "鶏むね肉", store: "イオン",       brand: nil, content_quantity: 500, content_unit: "g", pack_quantity: 1, pack_unit: "パック", price: 398, tax_rate: 8, days_ago: 2 },
        { item: "鶏むね肉", store: "業務スーパー", brand: nil, content_quantity: 500, content_unit: "g", pack_quantity: 1, pack_unit: "パック", price: 298, tax_rate: 8, days_ago: 9 },

        # キャベツ:1個
        { item: "キャベツ", store: "イオン",       brand: nil, content_quantity: 1, content_unit: "個", pack_quantity: 1, pack_unit: "袋", price: 198, tax_rate: 8, days_ago: 3 },
        { item: "キャベツ", store: "業務スーパー", brand: nil, content_quantity: 1, content_unit: "個", pack_quantity: 1, pack_unit: "袋", price: 148, tax_rate: 8, days_ago: 10 },

        # 醤油:1000ml×1本
        { item: "醤油", store: "イオン",       brand: "キッコーマン", content_quantity: 1000, content_unit: "ml", pack_quantity: 1, pack_unit: "本", price: 398, tax_rate: 8, days_ago: 6 },
        { item: "醤油", store: "業務スーパー", brand: "キッコーマン", content_quantity: 1000, content_unit: "ml", pack_quantity: 1, pack_unit: "本", price: 328, tax_rate: 8, days_ago: 13 },

        # ポテチ:60g×1袋
        { item: "ポテトチップス", store: "イオン",         brand: "カルビー", content_quantity: 60, content_unit: "g", pack_quantity: 1, pack_unit: "袋", price: 128, tax_rate: 8, days_ago: 4 },
        { item: "ポテトチップス", store: "セブンイレブン", brand: "カルビー", content_quantity: 60, content_unit: "g", pack_quantity: 1, pack_unit: "袋", price: 158, tax_rate: 8, days_ago: 8 },

        # チョコ:50g×1袋
        { item: "チョコレート", store: "イオン",         brand: "明治",    content_quantity: 50, content_unit: "g", pack_quantity: 1, pack_unit: "袋", price: 108, tax_rate: 8, days_ago: 5 },
        { item: "チョコレート", store: "セブンイレブン", brand: "明治",    content_quantity: 50, content_unit: "g", pack_quantity: 1, pack_unit: "袋", price: 138, tax_rate: 8, days_ago: 11 }
      ]

      purchases_data.each do |data|
        price_excluding_tax = data[:price].to_f / (1 + data[:tax_rate] * 0.01)
        unit_price = price_excluding_tax / data[:content_quantity] / data[:pack_quantity]

        demo.purchases.create!(
          item: items[data[:item]],
          store: stores[data[:store]],
          content_unit: content_units[data[:content_unit]],
          pack_unit: pack_units[data[:pack_unit]],
          brand: data[:brand],
          content_quantity: data[:content_quantity],
          pack_quantity: data[:pack_quantity],
          price: data[:price],
          unit_price: unit_price,
          tax_rate: data[:tax_rate],
          purchased_on: data[:days_ago].days.ago.to_date
        )
      end
    end

    puts "デモユーザーのデータをリセットしました。"
  end
end
