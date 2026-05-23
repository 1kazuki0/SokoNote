require "rails_helper"

RSpec.describe PurchaseUpdateForm, type: :model do
  let(:user) { create(:user) }
  let(:item) { create(:item, user: user, name: "牛乳") }
  let(:content_unit) { create(:content_unit, user: user, name: "ml") }
  let!(:purchase) do
    create(:purchase,
      user: user, item: item, content_unit: content_unit,
      price: 200, content_quantity: 1000, pack_quantity: 1, tax_rate: 0,
      unit_price: 0.2, purchased_on: "2026-01-01"
    )
  end

  let(:valid_attributes) do
    {
      category_name: "食品",
      item_name: "牛乳",
      brand: "明治",
      content_quantity: 1000,
      content_unit_name: "ml",
      pack_quantity: 1,
      pack_unit_name: "",
      store_name: "スーパーA",
      purchased_on: "2026-01-15",
      price: 250,
      tax_rate: 8
    }
  end

  # ===========================================================
  # 属性のデフォルト値
  # ===========================================================
  describe "属性のデフォルト値" do
    let(:form) { PurchaseUpdateForm.new }

    it "pack_quantityのデフォルトは 1" do
      expect(form.pack_quantity).to eq(1)
    end

    it "tax_rateのデフォルトは 0" do
      expect(form.tax_rate).to eq(0)
    end

    it "purchased_onのデフォルトは今日の日付" do
      expect(form.purchased_on).to eq(Date.today)
    end
  end

  # ===========================================================
  # バリデーション
  # ===========================================================
  describe "バリデーション" do
    context "有効な属性の場合" do
      it "valid?がtrue を返す" do
        form = PurchaseUpdateForm.new(valid_attributes)
        expect(form).to be_valid
      end
    end

    describe "category_name" do
      it "空でも有効(allow_blank)" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(category_name: ""))
        expect(form).to be_valid
      end

      it "31文字以上で無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(category_name: "a" * 31))
        expect(form).not_to be_valid
      end
    end

    describe "item_name" do
      it "空の場合無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(item_name: ""))
        expect(form).not_to be_valid
      end

      it "31文字以上で無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(item_name: "a" * 31))
        expect(form).not_to be_valid
      end
    end

    describe "brand" do
      it "空でも有効(allow_blank)" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(brand: ""))
        expect(form).to be_valid
      end

      it "31文字以上で無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(brand: "a" * 31))
        expect(form).not_to be_valid
      end
    end

    describe "content_quantity" do
      it "空の場合無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(content_quantity: nil))
        expect(form).not_to be_valid
      end

      it "0以下で無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(content_quantity: 0))
        expect(form).not_to be_valid
      end

      it "小数値で有効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(content_quantity: 0.5))
        expect(form).to be_valid
      end
    end

    describe "content_unit_name" do
      it "空の場合無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(content_unit_name: ""))
        expect(form).not_to be_valid
      end

      it "11文字以上で無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(content_unit_name: "a" * 11))
        expect(form).not_to be_valid
      end
    end

    describe "pack_quantity" do
      it "空の場合無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(pack_quantity: nil))
        expect(form).not_to be_valid
      end

      it "0で無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(pack_quantity: 0))
        expect(form).not_to be_valid
      end

      it "1で有効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(pack_quantity: 1))
        expect(form).to be_valid
      end
    end

    describe "pack_unit_name" do
      it "空でも有効(allow_blank)" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(pack_unit_name: ""))
        expect(form).to be_valid
      end

      it "11文字以上で無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(pack_unit_name: "a" * 11))
        expect(form).not_to be_valid
      end
    end

    describe "store_name" do
      it "空でも有効(allow_blank)" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(store_name: ""))
        expect(form).to be_valid
      end

      it "31文字以上で無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(store_name: "a" * 31))
        expect(form).not_to be_valid
      end
    end

    describe "purchased_on" do
      it "空の場合無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(purchased_on: nil))
        expect(form).not_to be_valid
      end
    end

    describe "price" do
      it "空の場合無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(price: nil))
        expect(form).not_to be_valid
      end

      it "0以下で無効" do
        form = PurchaseUpdateForm.new(valid_attributes.merge(price: 0))
        expect(form).not_to be_valid
      end
    end

    describe "tax_rate" do
      [0, 8, 10].each do |valid_rate|
        it "#{valid_rate} で有効" do
          form = PurchaseUpdateForm.new(valid_attributes.merge(tax_rate: valid_rate))
          expect(form).to be_valid
        end
      end

      [1, 5, 15].each do |invalid_rate|
        it "#{invalid_rate} で無効" do
          form = PurchaseUpdateForm.new(valid_attributes.merge(tax_rate: invalid_rate))
          expect(form).not_to be_valid
        end
      end
    end
  end

  # ===========================================================
  # before_validation コールバック (normalize_names)
  # ===========================================================
  describe "before_validation :normalize_names" do
    it "category_nameの前後の空白を削除する" do
      form = PurchaseUpdateForm.new(valid_attributes.merge(category_name: "  食品  "))
      form.valid?
      expect(form.category_name).to eq("食品")
    end

    it "item_nameの前後の空白を削除する" do
      form = PurchaseUpdateForm.new(valid_attributes.merge(item_name: "  牛乳  "))
      form.valid?
      expect(form.item_name).to eq("牛乳")
    end

    it "content_unit_nameの前後の空白を削除する" do
      form = PurchaseUpdateForm.new(valid_attributes.merge(content_unit_name: "  ml  "))
      form.valid?
      expect(form.content_unit_name).to eq("ml")
    end

    it "pack_unit_nameの前後の空白を削除する" do
      form = PurchaseUpdateForm.new(valid_attributes.merge(pack_unit_name: "  箱  "))
      form.valid?
      expect(form.pack_unit_name).to eq("箱")
    end

    it "store_nameの前後の空白を削除する" do
      form = PurchaseUpdateForm.new(valid_attributes.merge(store_name: "  スーパーA  "))
      form.valid?
      expect(form.store_name).to eq("スーパーA")
    end

    it "brandの前後の空白を削除する" do
      form = PurchaseUpdateForm.new(valid_attributes.merge(brand: "  明治  "))
      form.valid?
      expect(form.brand).to eq("明治")
    end

    it "全角空白も削除される" do
      form = PurchaseUpdateForm.new(valid_attributes.merge(item_name: "\u3000牛乳\u3000"))
      form.valid?
      expect(form.item_name).to eq("牛乳")
    end

    it "空白だけの値はnilになる" do
      form = PurchaseUpdateForm.new(valid_attributes.merge(brand: "   "))
      form.valid?
      expect(form.brand).to be_nil
    end
  end

  # ===========================================================
  # #update メソッド
  # ===========================================================
  describe "#update" do
    let(:form) do
      f = PurchaseUpdateForm.new(valid_attributes)
      f.user = user
      f.purchase = purchase
      f
    end

    context "有効な属性の場合" do
      it "true を返す" do
        expect(form.update).to be true
      end

      it "purchaseのpriceが更新される" do
        form.update
        expect(purchase.reload.price).to eq(250)
      end

      it "purchaseのbrandが更新される" do
        form.update
        expect(purchase.reload.brand).to eq("明治")
      end

      it "purchaseのpurchased_onが更新される" do
        form.update
        expect(purchase.reload.purchased_on).to eq(Date.parse("2026-01-15"))
      end

      it "purchaseのtax_rateが更新される" do
        form.update
        expect(purchase.reload.tax_rate).to eq(8)
      end

      it "Categoryが新規作成される" do
        expect { form.update }.to change(Category, :count).by(1)
      end

      it "ItemにCategoryが紐づく" do
        form.update
        expect(item.reload.category.name).to eq("食品")
      end

      it "Storeが新規作成される" do
        expect { form.update }.to change(Store, :count).by(1)
      end

      it "purchaseにStoreが紐づく" do
        form.update
        expect(purchase.reload.store.name).to eq("スーパーA")
      end
    end

    context "category_nameが空の場合" do
      let(:form) do
        f = PurchaseUpdateForm.new(valid_attributes.merge(category_name: ""))
        f.user = user
        f.purchase = purchase
        f
      end

      it "Categoryが作成されない" do
        expect { form.update }.not_to change(Category, :count)
      end

      it "Itemのcategoryはnil" do
        form.update
        expect(item.reload.category).to be_nil
      end
    end

    context "store_nameが空の場合" do
      let(:form) do
        f = PurchaseUpdateForm.new(valid_attributes.merge(store_name: ""))
        f.user = user
        f.purchase = purchase
        f
      end

      it "Storeが作成されない" do
        expect { form.update }.not_to change(Store, :count)
      end

      it "purchaseのstoreはnil" do
        form.update
        expect(purchase.reload.store).to be_nil
      end
    end

    context "pack_unit_nameが空の場合" do
      let(:form) do
        f = PurchaseUpdateForm.new(valid_attributes.merge(pack_unit_name: ""))
        f.user = user
        f.purchase = purchase
        f
      end

      it "PackUnitが作成されない" do
        expect { form.update }.not_to change(PackUnit, :count)
      end

      it "purchaseのpack_unit は nil" do
        form.update
        expect(purchase.reload.pack_unit).to be_nil
      end
    end

    context "既存のCategoryが存在する場合" do
      let!(:existing_category) { create(:category, user: user, name: "食品") }

      it "Categoryは新規作成されない" do
        expect { form.update }.not_to change(Category, :count)
      end

      it "既存のCategoryがItemに紐づく" do
        form.update
        expect(item.reload.category).to eq(existing_category)
      end
    end

    context "既存のStoreが存在する場合" do
      let!(:existing_store) { create(:store, user: user, name: "スーパーA") }

      it "Storeは新規作成されない" do
        expect { form.update }.not_to change(Store, :count)
      end

      it "既存のStoreがpurchaseに紐づく" do
        form.update
        expect(purchase.reload.store).to eq(existing_store)
      end
    end

    context "他のユーザーが同名Categoryを持っている場合" do
      let(:other_user) { create(:user) }
      let!(:other_category) { create(:category, user: other_user, name: "食品") }

      it "新しいCategoryがuser用に作成される" do
        expect { form.update }.to change(Category, :count).by(1)
      end

      it "作成されたCategoryは自分(user)に紐づく" do
        form.update
        expect(item.reload.category.user).to eq(user)
      end
    end

    context "無効な属性の場合" do
      let(:invalid_form) do
        f = PurchaseUpdateForm.new(valid_attributes.merge(item_name: ""))
        f.user = user
        f.purchase = purchase
        f
      end

      it "falseを返す" do
        expect(invalid_form.update).to be false
      end

      it "purchaseが更新されない" do
        original_price = purchase.price
        invalid_form.update
        expect(purchase.reload.price).to eq(original_price)
      end

      it "Categoryが作成されない" do
        expect { invalid_form.update }.not_to change(Category, :count)
      end

      it "Storeが作成されない" do
        expect { invalid_form.update }.not_to change(Store, :count)
      end
    end

    context "保存途中で例外が発生した場合(トランザクション)" do
      let(:form) do
        f = PurchaseUpdateForm.new(valid_attributes)
        f.user = user
        f.purchase = purchase
        f
      end

      before do
        # purchase.update! で例外を発生させる
        allow(purchase).to receive(:update!)
          .and_raise(ActiveRecord::RecordInvalid.new(purchase))
      end

      it "falseを返す" do
        expect(form.update).to be false
      end

      it "Categoryがロールバックされる(新規作成されない)" do
        expect { form.update }.not_to change(Category, :count)
      end

      it "Storeがロールバックされる(新規作成されない)" do
        expect { form.update }.not_to change(Store, :count)
      end

      it "purchaseが更新されない" do
        original_price = purchase.price
        form.update
        expect(purchase.reload.price).to eq(original_price)
      end

      it "errorsにメッセージが追加される" do
        form.update
        expect(form.errors[:base]).to be_present
      end
    end
  end
  # ===========================================================
  # 単価計算ロジック
  # ===========================================================
  describe "単価計算" do
    let(:form) do
      f = PurchaseUpdateForm.new(
        item_name: "牛乳",
        content_quantity: 1000,
        content_unit_name: "ml",
        pack_quantity: 1,
        purchased_on: Date.today,
        price: price,
        tax_rate: tax_rate
      )
      f.user = user
      f.purchase = purchase
      f
    end

    context "tax_rate: 0 (税抜) の場合" do
      let(:price) { 200 }
      let(:tax_rate) { 0 }

      it "unit_price = price / content_quantity / pack_quantity になる" do
        form.update
        # 200 / 1000 / 1 = 0.2
        expect(purchase.reload.unit_price).to be_within(0.001).of(0.2)
      end
    end

    context "tax_rate: 8 (税込8%) の場合" do
      let(:price) { 216 }
      let(:tax_rate) { 8 }

      it "税抜価格に変換してから単価計算される" do
        form.update
        # 216 / 1.08 = 200 → 200 / 1000 / 1 = 0.2
        expect(purchase.reload.unit_price).to be_within(0.001).of(0.2)
      end
    end

    context "tax_rate: 10 (税込10%) の場合" do
      let(:price) { 220 }
      let(:tax_rate) { 10 }

      it "税抜価格に変換してから単価計算される" do
        form.update
        # 220 / 1.10 = 200 → 200 / 1000 / 1 = 0.2
        expect(purchase.reload.unit_price).to be_within(0.001).of(0.2)
      end
    end
  end

  # ===========================================================
  # new_record? メソッド
  # ===========================================================
  describe "#new_record?" do
    it "常にfalseを返す" do
      form = PurchaseUpdateForm.new
      expect(form.new_record?).to be false
    end
  end
end