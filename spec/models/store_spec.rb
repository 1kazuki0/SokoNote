require 'rails_helper'

RSpec.describe Store, type: :model do
  # factory_botを参照
  let(:user) { create(:user) }          # store を保存する場合に備えて create
  let(:store) { build(:store, user: user) }

  describe "バリデーション" do
    it "全ての項目が正しく入力されていれば有効" do
      expect(store).to be_valid
    end

    # --- name ---
    describe "name" do
      it "空だと無効" do
        store.name = ""
        expect(store).to be_invalid
        expect(store.errors[:name]).to include("を入力してください")
      end

      it "nilだと無効" do
        store.name = nil
        expect(store).to be_invalid
        expect(store.errors[:name]).to include("を入力してください")
      end

      it "29文字なら有効（境界値）" do
        store.name = "a" * 29
        expect(store).to be_valid
      end

      it "30文字ちょうどなら有効(境界値)" do
        store.name = "a" * 30
        expect(store).to be_valid
      end

      it "31文字だと無効(境界値)" do
        store.name = "a" * 31
        expect(store).to be_invalid
        expect(store.errors[:name]).to include("は30文字以内で入力してください")
      end

      it "同一ユーザー内で重複すると無効" do
        create(:store, name: "セブン", user: user)
        duplicate_store = build(:store, name: "セブン", user: user)
        expect(duplicate_store).to be_invalid
        expect(duplicate_store.errors[:name]).to include("はすでに存在します")
      end

      it "別のユーザーなら同じnameでも有効" do
        other_user = create(:user)
        create(:store, name: "セブン", user: other_user)
        store.name = "セブン"
        expect(store).to be_valid
      end
    end

    # --- user ---
    describe "user" do
      it "nilだと無効(belongs_toによる)" do
        store.user = nil
        expect(store).to be_invalid
        expect(store.errors[:user]).to include("を入力してください")
      end
    end
  end

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "アソシエーション" do
    let(:store) { create(:store) }

    it "userをbelongs_toで関連づけている" do
      association = Store.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "purchasesをhas_manyで関連づけている" do
      association = Store.reflect_on_association(:purchases)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe "アソシエーション（optional: true）" do

    it "categoryがnilでもitemを保存できる" do
      item = build(:item, category: nil, user: user)
      expect(item.save).to be true
    end
  end

  describe "アソシエーション（dependent: :nullify)" do
    let(:store) { create(:store) }  # このブロックだけ create で上書き
    let(:purchase) { create(:purchase) }

    it "storeを削除してもpurchaseは削除されない" do
      expect { store.destroy }.to change(Purchase, :count).by(0)
    end
  end


  # ============================================================
  # コールバック
  # before_validation :normalize_name の動作確認
  # ============================================================
  describe "before_validation :normalize_name" do
    it "nameの前後の空白が削除される" do
      store.name = "  セブン  "
      store.valid?  # バリデーションを発火させて before_validation を走らせる
      expect(store.name).to eq "セブン"
    end

    it "nameが空白だけなら nil になる(結果presenceエラー)" do
      store.name = "   "
      expect(store).to be_invalid
      expect(store.name).to be_nil
      expect(store.errors[:name]).to include("を入力してください")
    end

    it "name内の前後空白が混じっている場合も空白削除される" do
      store.name = "\tセブン\n"
      store.valid?
      expect(store.name).to eq "セブン"
    end
  end
end
