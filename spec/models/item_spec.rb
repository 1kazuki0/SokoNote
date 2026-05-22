require 'rails_helper'

RSpec.describe Item, type: :model do
  # factory_botを参照
  let(:user) { create(:user) }
  let(:item) { build(:item, user: user) }

  describe "バリデーション" do
    it "全ての項目が正しく入力されていれば有効" do
      expect(item).to be_valid
    end

    # --- name ---
    describe "name" do
      it "空だと無効" do
        item.name = ""
        expect(item).to be_invalid
        expect(item.errors[:name]).to include("を入力してください")
      end

      it "nilだと無効" do
        item.name = nil
        expect(item).to be_invalid
        expect(item.errors[:name]).to include("を入力してください")
      end

      it "29文字なら有効（境界値）" do
        item.name = "a" * 29
        expect(item).to be_valid
      end

      it "30文字ちょうどなら有効(境界値)" do
        item.name = "a" * 30
        expect(item).to be_valid
      end

      it "31文字だと無効(境界値)" do
        item.name = "a" * 31
        expect(item).to be_invalid
        expect(item.errors[:name]).to include("は30文字以内で入力してください")
      end

      it "同一ユーザー内で重複すると無効" do
        create(:item, name: "牛乳", user: user)
        duplicate = build(:item, name: "牛乳", user: user)
        expect(duplicate).to be_invalid
        expect(duplicate.errors[:name]).to include("はすでに存在します")
      end

      it "別のユーザーなら同じnameでも有効" do
        other_user = create(:user)
        create(:item, name: "牛乳", user: other_user)
        item.name = "牛乳"
        expect(item).to be_valid
      end
    end

    # --- user ---
    describe "user" do
      it "nilだと無効(belongs_toによる)" do
        item.user = nil
        expect(item).to be_invalid
        expect(item.errors[:user]).to include("を入力してください")
      end
    end

    # --- category ---
    describe "category" do
      it "nilでも有効(optional: true)" do
        item.category = nil
        expect(item).to be_valid
      end

      it "存在するcategoryを指定すれば有効" do
        category = create(:category, user: user)
        item.category = category
        expect(item).to be_valid
      end
    end
  end
  # ============================================================
  # アソシエーション
  # ============================================================
  describe "アソシエーション" do
    let(:item) { create(:item) }

    it "userをbelongs_toで関連づけている" do
      association = Item.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "categoryをbelongs_toで関連づけている" do
      association = Item.reflect_on_association(:category)
      expect(association.macro).to eq(:belongs_to)
    end

    it "purchasesをhas_manyで関連づけている" do
      association = Item.reflect_on_association(:purchases)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe "アソシエーション（optional: true）" do
    it "categoryがnilでもitemを保存できる" do
      item = build(:item, category: nil, user: user)
      expect(item.save).to be true
    end
  end

  describe "アソシエーション（dependent: :destroy）" do
    let(:item) { create(:item) }
    let!(:purchase) { create(:purchase, item: item) } # !を入れることで、テスト実行前にデータを作成する（通常は:purchaseを初めて使ったタイミング）

    it "itemを削除するとpurchasesも削除される" do
      expect { item.destroy }.to change(Purchase, :count).by(-1)
    end
  end

  # ============================================================
  # コールバック
  # before_validation :normalize_name の動作確認
  # ============================================================
  describe "before_validation :normalize_name" do
    it "nameの前後の半角空白が削除される" do
      item.name = "  牛乳  "
      item.valid?
      expect(item.name).to eq "牛乳"
    end

    it "nameの前後の全角空白が削除される" do
      item.name = "　牛乳　"
      item.valid?
      expect(item.name).to eq "牛乳"
    end

    it "nameが半角空白だけなら nil になる" do
      item.name = "   "
      expect(item).to be_invalid
      expect(item.name).to be_nil
      expect(item.errors[:name]).to include("を入力してください")
    end

    it "nameが全角空白だけなら nil になる" do
      item.name = "　　　"
      expect(item).to be_invalid
      expect(item.name).to be_nil
      expect(item.errors[:name]).to include("を入力してください")
    end
  end
end
