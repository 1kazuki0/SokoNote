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

    # --- user ---
    describe "user" do
      it "nilだと無効(belongs_toによる)" do
        category.user = nil
        expect(category).to be_invalid
        expect(category.errors[:user]).to include("を入力してください")
      end
    end
  end

  # ============================================================
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

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "アソシエーション" do
    describe "belongs_to :user" do
      it "userに紐づく" do
        saved_category = create(:category, user: user)
        expect(saved_category.user).to eq user
      end
    end

    describe "has_many :items (dependent: :nullify)" do
      it "categoryを削除すると関連itemsのcategory_idがnilになる" do
        saved_category = create(:category, user: user)
        item = create(:item, user: user, category: saved_category)

        expect { saved_category.destroy }.to change { item.reload.category_id }.from(saved_category.id).to(nil)
      end

      it "categoryを削除してもitem自体は削除されない" do
        saved_category = create(:category, user: user)
        create(:item, user: user, category: saved_category)

        expect { saved_category.destroy }.not_to change(Item, :count)
      end
    end
  end
end
