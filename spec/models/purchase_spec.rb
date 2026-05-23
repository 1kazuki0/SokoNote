require 'rails_helper'

RSpec.describe Purchase, type: :model do
  # --- factory_botを参照 ---
  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }
  let(:store) { create(:store, user: user) }
  let(:content_unit) { create(:content_unit, user: user) }
  let(:pack_unit) { create(:pack_unit, user: user) }
  let(:purchase) do
    build(:purchase, user: user, item: item, store: store,
                     content_unit: content_unit, pack_unit: pack_unit)
  end

  describe "バリデーション" do
    it "全ての項目が正しく入力されていれば有効" do
      expect(purchase).to be_valid
    end

    # ============================================================
    # brand
    # ============================================================
    describe "brand" do
      it "空でも有効(allow_blank: true)" do
        purchase.brand = ""
        expect(purchase).to be_valid
      end

      it "nilでも有効(allow_blank: true)" do
        purchase.brand = nil
        expect(purchase).to be_valid
      end

      it "29文字なら有効（境界値）" do
        purchase.brand = "a" * 29
        expect(purchase).to be_valid
      end

      it "30文字ちょうどなら有効(境界値)" do
        purchase.brand = "a" * 30
        expect(purchase).to be_valid
      end

      it "31文字だと無効(境界値)" do
        purchase.brand = "a" * 31
        expect(purchase).to be_invalid
        expect(purchase.errors[:brand]).to include("は30文字以内で入力してください")
      end
    end

    # ============================================================
    # content_quantity
    # ============================================================
    describe "content_quantity" do
      it "nilだと無効" do
        purchase.content_quantity = nil
        expect(purchase).to be_invalid
        expect(purchase.errors[:content_quantity]).to include("を入力してください")
      end

      it "0だと無効(greater_than: 0)" do
        purchase.content_quantity = 0
        expect(purchase).to be_invalid
        expect(purchase.errors[:content_quantity]).to include("は0より大きい値にしてください")
      end

      it "負数だと無効" do
        purchase.content_quantity = -1
        expect(purchase).to be_invalid
        expect(purchase.errors[:content_quantity]).to include("は0より大きい値にしてください")
      end

      it "文字列だと無効" do
        purchase.content_quantity = "abc"
        expect(purchase).to be_invalid
        expect(purchase.errors[:content_quantity]).to include("は数値で入力してください")
      end

      it "小数でも有効" do
        purchase.content_quantity = 0.5
        expect(purchase).to be_valid
      end

      it "大きな値でも有効" do
        purchase.content_quantity = 99999.99
        expect(purchase).to be_valid
      end
    end

    # ============================================================
    # pack_quantity
    # ============================================================
    describe "pack_quantity" do
      it "nilだと無効" do
        purchase.pack_quantity = nil
        expect(purchase).to be_invalid
        expect(purchase.errors[:pack_quantity]).to include("を入力してください")
      end

      it "0だと無効(greater_than_or_equal_to: 1)" do
        purchase.pack_quantity = 0
        expect(purchase).to be_invalid
        expect(purchase.errors[:pack_quantity]).to include("は1以上の値にしてください")
      end

      it "1なら有効(境界値)" do
        purchase.pack_quantity = 1
        expect(purchase).to be_valid
      end

      it "小数だと無効(only_integer)" do
        purchase.pack_quantity = 1.5
        expect(purchase).to be_invalid
        expect(purchase.errors[:pack_quantity]).to include("は整数で入力してください")
      end

      it "負数だと無効" do
        purchase.pack_quantity = -1
        expect(purchase).to be_invalid
        expect(purchase.errors[:pack_quantity]).to include("は1以上の値にしてください")
      end
    end

    # ============================================================
    # price
    # ============================================================
    describe "price" do
      it "nilだと無効" do
        purchase.price = nil
        expect(purchase).to be_invalid
        expect(purchase.errors[:price]).to include("を入力してください")
      end

      it "0だと無効(greater_than: 0)" do
        purchase.price = 0
        expect(purchase).to be_invalid
        expect(purchase.errors[:price]).to include("は0より大きい値にしてください")
      end

      it "負数だと無効" do
        purchase.price = -100
        expect(purchase).to be_invalid
        expect(purchase.errors[:price]).to include("は0より大きい値にしてください")
      end

      it "小数だと無効(only_integer)" do
        purchase.price = 100.5
        expect(purchase).to be_invalid
        expect(purchase.errors[:price]).to include("は整数で入力してください")
      end

      it "正の整数なら有効" do
        purchase.price = 100
        expect(purchase).to be_valid
      end
    end

    # ============================================================
    # unit_price
    # ============================================================
    describe "unit_price" do
      it "nilだと無効" do
        purchase.unit_price = nil
        expect(purchase).to be_invalid
        expect(purchase.errors[:unit_price]).to include("を入力してください")
      end

      it "0だと無効(greater_than: 0)" do
        purchase.unit_price = 0
        expect(purchase).to be_invalid
        expect(purchase.errors[:unit_price]).to include("は0より大きい値にしてください")
      end

      it "負数だと無効" do
        purchase.unit_price = -10
        expect(purchase).to be_invalid
        expect(purchase.errors[:unit_price]).to include("は0より大きい値にしてください")
      end

      it "小数でも有効" do
        purchase.unit_price = 50.5
        expect(purchase).to be_valid
      end
    end

    # ============================================================
    # tax_rate
    # ============================================================
    describe "tax_rate" do
      it "nilだと無効" do
        purchase.tax_rate = nil
        expect(purchase).to be_invalid
        expect(purchase.errors[:tax_rate]).to include("を入力してください")
      end

      it "一覧外の値(5)だと無効" do
        purchase.tax_rate = 5
        expect(purchase).to be_invalid
        expect(purchase.errors[:tax_rate]).to include("は一覧にありません")
      end

      it "0なら有効" do
        purchase.tax_rate = 0
        expect(purchase).to be_valid
      end

      it "8なら有効" do
        purchase.tax_rate = 8
        expect(purchase).to be_valid
      end

      it "10なら有効" do
        purchase.tax_rate = 10
        expect(purchase).to be_valid
      end
    end

    # ============================================================
    # purchased_on
    # ============================================================
    describe "purchased_on" do
      it "nilだと無効" do
        purchase.purchased_on = nil
        expect(purchase).to be_invalid
        expect(purchase.errors[:purchased_on]).to include("を入力してください")
      end

      it "日付文字列なら有効" do
        purchase.purchased_on = "2026/01/01"
        expect(purchase).to be_valid
      end

      it "Dateオブジェクトなら有効" do
        purchase.purchased_on = Date.new(2026, 1, 1)
        expect(purchase).to be_valid
      end
    end
  end

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "アソシエーション" do
    let(:purchase) { create(:purchase) }

    it "userをbelongs_toで関連づけている" do
      association = Purchase.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "itemをbelongs_toで関連づけている" do
      association = Purchase.reflect_on_association(:item)
      expect(association.macro).to eq(:belongs_to)
    end

    it "storeをbelongs_toで関連づけている" do
      association = Purchase.reflect_on_association(:store)
      expect(association.macro).to eq(:belongs_to)
    end

    it "content_unitをbelongs_toで関連づけている" do
      association = Purchase.reflect_on_association(:content_unit)
      expect(association.macro).to eq(:belongs_to)
    end

    it "pack_unitをbelongs_toで関連づけている" do
      association = Purchase.reflect_on_association(:pack_unit)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "アソシエーション（optional: true）" do
    it "storeがnilでもpurchaseを保存できる" do
      purchase = build(:purchase, store: nil, user: user, item: item, content_unit: content_unit, pack_unit: pack_unit)
      expect(purchase.save).to be true
    end

    it "pack_unitがnilでもpurchaseを保存できる" do
      purchase = build(:purchase, store: store, user: user, item: item, content_unit: content_unit, pack_unit: nil)
      expect(purchase.save).to be true
    end
  end

  # ============================================================
  # コールバック
  # before_validation :normalize_brand の動作確認
  # ============================================================
  describe "before_validation :normalize_brand" do
    it "brandの前後の半角空白が削除される" do
      purchase.brand = "  ブランド  "
      purchase.valid?
      expect(purchase.brand).to eq "ブランド"
    end

    it "brandの前後の全角空白が削除される" do
      purchase.brand = "　ブランド　"
      purchase.valid?
      expect(purchase.brand).to eq "ブランド"
    end

    it "brandが半角空白だけなら nil になる" do
      purchase.brand = "   "
      purchase.valid?
      expect(purchase.brand).to be_nil
    end

    it "brandが全角空白だけなら nil になる" do
      purchase.brand = "　　　"
      purchase.valid?
      expect(purchase.brand).to be_nil
    end

    it "brandがnilならnilのまま" do
      purchase.brand = nil
      purchase.valid?
      expect(purchase.brand).to be_nil
    end
  end
end
