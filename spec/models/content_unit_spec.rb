require 'rails_helper'

RSpec.describe ContentUnit, type: :model do
  # factory_botを参照
  let(:user) { create(:user) }
  let(:content_unit) { build(:content_unit, user: user) }

  describe "バリデーション" do
    it "全ての項目が正しく入力されていれば有効" do
      expect(content_unit).to be_valid
    end

    # --- name ---
    describe "name" do
      it "空だと無効" do
        content_unit.name = ""
        expect(content_unit).to be_invalid
        expect(content_unit.errors[:name]).to include("を入力してください")
      end

      it "nilだと無効" do
        content_unit.name = nil
        expect(content_unit).to be_invalid
        expect(content_unit.errors[:name]).to include("を入力してください")
      end

      it "10文字ちょうどなら有効(境界値)" do
        content_unit.name = "a" * 10
        expect(content_unit).to be_valid
      end

      it "11文字だと無効(境界値)" do
        content_unit.name = "a" * 11
        expect(content_unit).to be_invalid
        expect(content_unit.errors[:name]).to include("は10文字以内で入力してください")
      end

      it "同一ユーザー内で重複すると無効" do
        create(:content_unit, name: "g", user: user)
        duplicate = build(:content_unit, name: "g", user: user)
        expect(duplicate).to be_invalid
        expect(duplicate.errors[:name]).to include("はすでに存在します")
      end

      it "別のユーザーなら同じnameでも有効" do
        other_user = create(:user)
        create(:content_unit, name: "g", user: other_user)
        content_unit.name = "g"
        expect(content_unit).to be_valid
      end
    end

    # --- user ---
    describe "user" do
      it "nilだと無効(belongs_toによる)" do
        content_unit.user = nil
        expect(content_unit).to be_invalid
        expect(content_unit.errors[:user]).to include("を入力してください")
      end
    end
  end

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "アソシエーション" do
    let(:content_unit) { create(:content_unit) }

    it "userをbelongs_toで関連づけている" do
      association = ContentUnit.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "purchasesをhas_manyで関連づけている" do
      association = ContentUnit.reflect_on_association(:purchases)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe "アソシエーション（dependent: :restrict_with_error）" do
    let(:content_unit) { create(:content_unit) }
    let!(:purchase) { create(:purchase, content_unit: content_unit) }

    it "purchaseが紐づいているcontent_unitは削除できない" do
      expect(content_unit.destroy).to be false
    end
    
    it "削除しようとするとエラーメッセージが追加される" do
      content_unit.destroy
      expect(content_unit.errors[:base]). to be_present
    end
  end

  # ============================================================
  # コールバック
  # before_validation :normalize_name の動作確認
  # ============================================================
  describe "before_validation :normalize_name" do
    it "nameの前後の半角空白が削除される" do
      content_unit.name = "  g  "
      content_unit.valid?
      expect(content_unit.name).to eq "g"
    end

    it "nameの前後の全角空白が削除される" do
      content_unit.name = "　g　"
      content_unit.valid?
      expect(content_unit.name).to eq "g"
    end

    it "nameが半角空白だけなら nil になる" do
      content_unit.name = "   "
      expect(content_unit).to be_invalid
      expect(content_unit.name).to be_nil
      expect(content_unit.errors[:name]).to include("を入力してください")
    end

    it "nameが全角空白だけなら nil になる" do
      content_unit.name = "　　　"
      expect(content_unit).to be_invalid
      expect(content_unit.name).to be_nil
      expect(content_unit.errors[:name]).to include("を入力してください")
    end
  end
end
