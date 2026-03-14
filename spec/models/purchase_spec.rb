require "rails_helper"

RSpec.describe Purchase, type: :model do
  let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }
  let(:category) { user.categories.create(name: "食品") }
  let(:store) { user.stores.create(name: "スーパー大阪店") }
  let(:item) { category.items.create(name: "ハム", user: user) }

  describe "バリデーション" do
    context "無効の場合" do
      it "ブランド名が51文字なら無効" do
        purchase = item.purchases.new(brand: "a" * 51, content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "内容量が空白なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: nil, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "内容量が0なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 0, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "内容量が-1なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: -1, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "内容量の単位が11文字なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "a" * 11, pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "パック数が空白なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: nil, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "パック数が小数なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 0.1, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "パック数が0なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 0, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "パック数が-1なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: -1, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "パック数の単位が11文字なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "a" * 11, price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "価格が空白なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: nil, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "価格が小数点なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 0.1, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "価格が0なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 0, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "価格が-1なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: -1, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "単価が0なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 0, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "単価が-1なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: -1, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "税が空白なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: nil, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "税が1なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 1, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_invalid
      end

      it "購入日が空白なら無効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: nil, user: user, store: store)
        expect(purchase).to be_invalid
      end
    end

    context "有効の場合" do
      it "ブランド名が無くても有効" do
        purchase = item.purchases.new(brand: nil, content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "ブランド名が50文字なら有効" do
        purchase = item.purchases.new(brand: "a" * 50, content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "ブランド名が49文字なら有効" do
        purchase = item.purchases.new(brand: "a" * 49, content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "内容量が1なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 1, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "内容量の単位がなくても有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: nil, pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "内容量の単位が10文字なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "a" * 10, pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "内容量の単位が9文字なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "a" * 9, pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "パック数が整数なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 1, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "パック数が1なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 1, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "パック数の単位がなくても有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: nil, price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "パック数の単位が10文字なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "a" * 10, price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "パック数の単位が9文字なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "a" * 9, price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "価格が整数なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 100, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "価格が1なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 1, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "単価が1なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 1, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "税が0なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "税が8なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 8, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "税が10なら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 10, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end

      it "全ての値が入っていたら有効" do
        purchase = item.purchases.new(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: 3, pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2025/4/1", user: user, store: store)
        expect(purchase).to be_valid
      end
    end
  end
end
