require 'rails_helper'

RSpec.describe Category, type: :model do
  # factory_botを参照
  let(:user) { create(:user) }
  let(:category) { build(:category, user: user) }

  describe "バリデーション" do
    it "全ての項目が正しく入力されていれば有効" do
      expect(category).to be_valid
    end

    # --- name ---
    describe "name" do
      it "空だと無効" do
        category.name = ""
        expect(category).to be_invalid
        expect(category.errors[:name]).to include("を入力してください")
      end

      it "nilだと無効" do
        category.name = nil
        expect(category).to be_invalid
        expect(category.errors[:name]).to include("を入力してください")
      end

      it "29文字なら有効（境界線)" do
        category.name = "a" * 29
        expect(category).to be_valid
      end

      it "30文字ちょうどなら有効(境界値)" do
        category.name = "a" * 30
        expect(category).to be_valid
      end

      it "31文字だと無効(境界値)" do
        category.name = "a" * 31
        expect(category).to be_invalid
        expect(category.errors[:name]).to include("は30文字以内で入力してください")
      end

      it "同一ユーザー内で重複すると無効" do
        create(:category, name: "食品", user: user)
        duplicate_category = build(:category, name: "食品", user: user)
        expect(duplicate_category).to be_invalid
        expect(duplicate_category.errors[:name]).to include("はすでに存在します")
      end

      it "別のユーザーなら同じnameでも有効" do
        other_user = create(:user)
        create(:category, name: "食品", user: other_user)
        category.name = "食品"
        expect(category).to be_valid
      end
    end
  end

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "アソシエーション" do
    let(:category) { create(:category) }  # このブロックだけ create で上書き

    it "userをbelongs_toで関連づけている" do
      association = Category.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "itemsをhas_manyで関連づけている" do
      association = Category.reflect_on_association(:items)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe "アソシエーション（dependent: :nullify)" do
    let(:category) { create(:category) }  # このブロックだけ create で上書き
    let!(:item) { create(:item, category: category) }

    it "categoryを削除してもitemは削除されない" do
      expect { category.destroy }.to change(Item, :count).by(0)
      expect(item.reload.category_id).to be_nil
    end
  end

  # ============================================================
  # コールバック
  # before_validation :normalize_name の動作確認
  # ============================================================
  describe "before_validation :normalize_name" do
    it "nameの前後の空白が削除される" do
      category.name = "  食品  "
      category.valid?
      expect(category.name).to eq "食品"
    end

    it "nameが空白だけなら nil になる(結果presenceエラー)" do
      category.name = "   "
      expect(category).to be_invalid
      expect(category.name).to be_nil
      expect(category.errors[:name]).to include("を入力してください")
    end

    it "name内の前後の特殊空白文字も削除される" do
      category.name = "\t食品\n"
      category.valid?
      expect(category.name).to eq "食品"
    end
  end
end
