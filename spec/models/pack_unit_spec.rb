require 'rails_helper'

RSpec.describe PackUnit, type: :model do
  # factory_botを参照
  let(:user) { create(:user) }
  let(:pack_unit) { build(:pack_unit, user: user) }

  describe "バリデーション" do
    it "全ての項目が正しく入力されていれば有効" do
      expect(pack_unit).to be_valid
    end

    # --- name ---
    describe "name" do
      it "空だと無効" do
        pack_unit.name = ""
        expect(pack_unit).to be_invalid
        expect(pack_unit.errors[:name]).to include("を入力してください")
      end

      it "nilだと無効" do
        pack_unit.name = nil
        expect(pack_unit).to be_invalid
        expect(pack_unit.errors[:name]).to include("を入力してください")
      end

      it "9文字なら有効（境界値）" do
        pack_unit.name = "a" * 9
        expect(pack_unit).to be_valid
      end

      it "10文字ちょうどなら有効(境界値)" do
        pack_unit.name = "a" * 10
        expect(pack_unit).to be_valid
      end

      it "11文字だと無効(境界値)" do
        pack_unit.name = "a" * 11
        expect(pack_unit).to be_invalid
        expect(pack_unit.errors[:name]).to include("は10文字以内で入力してください")
      end

      it "同一ユーザー内で重複すると無効" do
        create(:pack_unit, name: "箱", user: user)
        duplicate = build(:pack_unit, name: "箱", user: user)
        expect(duplicate).to be_invalid
        expect(duplicate.errors[:name]).to include("はすでに存在します")
      end

      it "別のユーザーなら同じnameでも有効" do
        other_user = create(:user)
        create(:pack_unit, name: "箱", user: other_user)
        pack_unit.name = "箱"
        expect(pack_unit).to be_valid
      end
    end

    # --- user ---
    describe "user" do
      it "nilだと無効(belongs_toによる)" do
        pack_unit.user = nil
        expect(pack_unit).to be_invalid
        expect(pack_unit.errors[:user]).to include("を入力してください")
      end
    end
  end

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "アソシエーション" do
    let(:pack_unit) { create(:pack_unit) }

    it "userをbelongs_toで関連づけている" do
      association = PackUnit.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "purchasesをhas_manyで関連づけている" do
      association = PackUnit.reflect_on_association(:purchases)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe "アソシエーション（dependent: :nullify)" do
    let(:pack_unit) { create(:pack_unit) }  # このブロックだけ create で上書き
    let!(:purchase) { create(:purchase, pack_unit: pack_unit) }

    it "pack_unitを削除すると、紐づくpurchaseのpack_unit_idがnilになる" do
      pack_unit.destroy
      expect(purchase.reload.pack_unit_id).to be_nil
    end
  end

  # ============================================================
  # コールバック
  # before_validation :normalize_name の動作確認
  # ============================================================
  describe "before_validation :normalize_name" do
    it "nameの前後の半角空白が削除される" do
      pack_unit.name = "  箱  "
      pack_unit.valid?
      expect(pack_unit.name).to eq "箱"
    end

    it "nameの前後の全角空白が削除される" do
      pack_unit.name = "　箱　"
      pack_unit.valid?
      expect(pack_unit.name).to eq "箱"
    end

    it "nameが半角空白だけなら nil になる" do
      pack_unit.name = "   "
      expect(pack_unit).to be_invalid
      expect(pack_unit.name).to be_nil
      expect(pack_unit.errors[:name]).to include("を入力してください")
    end

    it "nameが全角空白だけなら nil になる" do
      pack_unit.name = "　　　"
      expect(pack_unit).to be_invalid
      expect(pack_unit.name).to be_nil
      expect(pack_unit.errors[:name]).to include("を入力してください")
    end
  end
end
