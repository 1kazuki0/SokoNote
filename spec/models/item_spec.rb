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

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "アソシエーション" do
    describe "belongs_to :user" do
      it "userに紐づく" do
        saved = create(:item, user: user)
        expect(saved.user).to eq user
      end
    end

    describe "belongs_to :category (optional: true)" do
      it "categoryに紐づく" do
        category = create(:category, user: user)
        saved = create(:item, user: user, category: category)
        expect(saved.category).to eq category
      end

      it "categoryがnilでも保存できる" do
        saved = build(:item, :not_category_item, user: user)
        expect(saved).to be_valid
        expect { saved.save! }.not_to raise_error
      end
    end

    describe "has_many :purchases (dependent: :destroy)" do
      it "itemを削除すると関連purchasesも削除される" do
        saved_item = create(:item, user: user)
        create(:purchase, user: user, item: saved_item)

        expect { saved_item.destroy }.to change(Purchase, :count).by(-1)
      end

      it "複数のpurchaseがあっても全て削除される" do
        saved_item = create(:item, user: user)
        create_list(:purchase, 3, user: user, item: saved_item)

        expect { saved_item.destroy }.to change(Purchase, :count).by(-3)
      end
    end
  end
end
