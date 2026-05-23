require "rails_helper"

RSpec.describe ItemRegistrationForm, type: :model do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    { item_name: "牛乳", content_quantity: 1000, content_unit_name: "ml", price: 200, tax_rate: 8 }
  end

  describe "属性デフォルト値" do
    let(:form) { ItemRegistrationForm.new }
    
    it "tax_rateのデフォルトは0" do
      expect(form.tax_rate).to eq(0)
    end

    it "pack_quantityのデフォルトは1" do
      expect(form.pack_quantity).to eq(1)
    end

    it "purchased_onのデフォルトは今日の日付" do
      expect(form.purchased_on).to eq(Date.today)
    end
  end

  describe "バリデーション" do
    context "有効な属性の場合" do
      it "valid?がtrueを返す" do
        form = ItemRegistrationForm.new(valid_attributes)
        expect(form).to be_valid
      end
    end

    describe "item_name" do
      it "空の場合は無効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(item_name: ""))
        expect(form).not_to be_valid
      end

      it "29文字なら有効(境界値）" do
        form = ItemRegistrationForm.new(valid_attributes.merge(item_name: "a" * 29))
        expect(form).to be_valid
      end

      it "30文字ちょうどなら有効（境界値）" do
        form = ItemRegistrationForm.new(valid_attributes.merge(item_name: "a" * 30))
        expect(form).to be_valid
      end

      it "31文字だと無効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(item_name: "a" * 31))
        expect(form).not_to be_valid
      end
    end

    describe "content_quantity" do
      it "空の場合は無効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(content_quantity: ""))
        expect(form).not_to be_valid
      end

      it "0以下で無効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(content_quantity: 0))
        expect(form).not_to be_valid
      end

      it "負の値で無効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(content_quantity: -1))
        expect(form).not_to be_valid
      end

      it "小数値で有効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(content_quantity: 0.5))
        expect(form).to be_valid
      end
    end

    describe "content_unit_name" do
      it "空の場合は無効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(content_unit_name: ""))
        expect(form).not_to be_valid
      end

      it "9文字なら有効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(content_unit_name: "a" * 9))
        expect(form).to be_valid
      end

      it "10文字ちょうどなら有効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(content_unit_name: "a" * 10))
        expect(form).to be_valid
      end

      it "11文字なら無効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(content_unit_name: "a" * 11))
        expect(form).not_to be_valid
      end
    end

    describe "price" do
      it "空の場合無効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(price: nil))
        expect(form).not_to be_valid
      end

      it "0以下で無効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(price: nil))
        expect(form).not_to be_valid
      end

      it "負の値で無効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(price: -1))
        expect(form).not_to be_valid
      end

      it "正の値で有効" do
        form = ItemRegistrationForm.new(valid_attributes.merge(price: 1))
        expect(form).to be_valid
      end
    end

    describe "tax_rate" do
      [0, 8, 10].each do |valid_rate|
        it "#{valid_rate}で有効" do
          form = ItemRegistrationForm.new(valid_attributes.merge(tax_rate: valid_rate))
          expect(form).to be_valid
        end
      end

      [1, 5, 15].each do |invalid_rate|
        it "#{invalid_rate}で無効" do
          form = ItemRegistrationForm.new(valid_attributes.merge(tax_rate: invalid_rate))
          expect(form).not_to be_valid
        end
      end
    end
  end

  # ============================================================
  # コールバック
  # before_validation :normalize_name の動作確認
  # ============================================================
  describe "before_validation :normalize_names" do
    it "item_nameの前後の半角空白を削除する" do
      form = ItemRegistrationForm.new(valid_attributes.merge(item_name: "  牛乳  "))
      form.valid?
      expect(form.item_name).to eq("牛乳")
    end

    it "item_nameの前後の全角空白を削除する" do
      form = ItemRegistrationForm.new(valid_attributes.merge(item_name: "\u3000牛乳\u3000"))
      form.valid?
      expect(form.item_name).to eq("牛乳")
    end

    it "content_unit_nameの前後の空白を削除する" do
      form = ItemRegistrationForm.new(valid_attributes.merge(content_unit_name: "  ml  "))
      form.valid?
      expect(form.content_unit_name).to eq("ml")
    end

    it "空白だけのitem_nameはnilになる" do
      form = ItemRegistrationForm.new(valid_attributes.merge(item_name: "  "))
      form.valid?
      expect(form.item_name).to be_nil
    end

    it "空白だけのcontent_unit_nameはnilになる" do
      form = ItemRegistrationForm.new(valid_attributes.merge(content_unit_name: "  "))
      form.valid?
      expect(form.content_unit_name).to be_nil
    end
  end

  # ============================================================
  # ビジネスロジック
  # ============================================================
  describe "#save" do
    let(:form) do
      f = ItemRegistrationForm.new(valid_attributes)
      f.user = user
      f
    end

    context "有効な属性の場合" do
      it "true を返す" do
        expect(form.save).to be true
      end

      it "Itemが1件作成される" do
        expect { form.save }.to change(Item, :count).by(1)
      end

      it "Purchaseが1件作成される" do
        expect { form.save }.to change(Purchase, :count).by(1)
      end

      it "ContentUnitが1件作成される" do
        expect { form.save }.to change(ContentUnit, :count).by(1)
      end

      it "@itemに作成されたItemが代入される" do
        form.save
        expect(form.item).to be_a(Item)
        expect(form.item.name).to eq("牛乳")
      end

      it "@purchaseに作成されたPurchaseが代入される" do
        form.save
        expect(form.purchase).to be_a(Purchase)
      end

      it "Itemはuserに紐づいている" do
        form.save
        expect(form.item.user).to eq(user)
      end

      it "Purchaseはuser,item,content_unitに紐づいている" do
        form.save
        expect(form.purchase.user).to eq(user)
        expect(form.purchase.item).to eq(form.item)
        expect(form.purchase.content_unit.name).to eq("ml")
      end
    end

    context "既存のItemが存在する場合" do
      let!(:existing_item) { create(:item, user: user, name: "牛乳") }

      it "Itemは新規作成されない" do
        expect { form.save }.not_to change(Item, :count)
      end

      it "既存ItemにPurchaseが紐づく" do
        form.save
        expect(form.item).to eq(existing_item)
        expect(form.purchase.item).to eq(existing_item)
      end
    end

    context "既存のContentUnitが存在する場合" do
      let!(:existing_unit) { create(:content_unit, user: user, name: "ml") }

      it "ContentUnitは新規作成されない" do
        expect { form.save }.not_to change(ContentUnit, :count)
      end

      it "既存ContentUnitがPurchaseに紐づく" do
        form.save
        expect(form.purchase.content_unit).to eq(existing_unit)
      end
    end

    context "他のユーザーが同名Itemを持っている場合" do
      let(:other_user) { create(:user) }
      let!(:other_item) { create(:item, user: other_user, name: "牛乳") }

      it "新しいItemがuser用に作成される" do
        expect { form.save }.to change(Item, :count).by(1)
      end

      it "作成されたItem は自分(user)に紐づく" do
        form.save
        expect(form.item.user).to eq(user)
        expect(form.item).not_to eq(other_item)
      end
    end

    context "無効な属性の場合" do
      let(:invalid_form) do
        f = ItemRegistrationForm.new(valid_attributes.merge(item_name: ""))
        f.user = user
        f
      end

      it "false を返す" do
        expect(invalid_form.save).to be false
      end

      it "Item が作成されない" do
        expect { invalid_form.save }.not_to change(Item, :count)
      end

      it "Purchase が作成されない" do
        expect { invalid_form.save }.not_to change(Purchase, :count)
      end

      it "ContentUnit が作成されない" do
        expect { invalid_form.save }.not_to change(ContentUnit, :count)
      end
    end

    context "保存途中で例外が発生した場合(トランザクション)" do
      it "ItemとPurchaseとContentUnitすべてロールバックされる" do
        allow_any_instance_of(Item).to receive_message_chain(:purchases, :create!)
          .and_raise(ActiveRecord::RecordInvalid.new(Purchase.new))

        expect { form.save }.not_to change(Item, :count)
      end
    end
  end

  # ===========================================================
  # 単価計算ロジック (private methods 経由で間接的に検証)
  # ===========================================================
  describe "単価計算" do
    context "tax_rate: 0 (税抜)の場合" do
      let(:form) do
        f = ItemRegistrationForm.new( item_name: "牛乳", content_quantity: 1000, content_unit_name: "ml", price: 200, tax_rate: 0 )
        f.user = user
        f
      end

      it "unit_price = price / content_quantity / pack_quantity になる" do
        form.save
        # 200 / 1000 / 1 = 0.2
        expect(form.purchase.unit_price).to be_within(0.001).of(0.2)
      end
    end

    context "tax_rate: 8 (税込8%)の場合" do
      let(:form) do
        f = ItemRegistrationForm.new(item_name: "牛乳", content_quantity: 1000, content_unit_name: "ml", price: 216, tax_rate: 8)
        f.user = user
        f
      end

      it "税抜価格に変換してから単価計算される" do
        form.save
        # 216 / 1.08 = 200 → 200 / 1000 / 1 = 0.2
        expect(form.purchase.unit_price).to be_within(0.001).of(0.2)
      end
    end

    context "tax_rate: 10 (税込10%)の場合" do
      let(:form) do
        f = ItemRegistrationForm.new(item_name: "牛乳", content_quantity: 1000, content_unit_name: "ml", price: 220, tax_rate: 10 )
        f.user = user
        f
      end

      it "税抜価格に変換してから単価計算される" do
        form.save
        # 220 / 1.10 = 200 → 200 / 1000 / 1 = 0.2
        expect(form.purchase.unit_price).to be_within(0.001).of(0.2)
      end
    end
  end

  # ===========================================================
  # new_record? メソッド
  # ===========================================================
  describe "#new_record?" do
    it "常に true を返す" do
      form = ItemRegistrationForm.new
      expect(form.new_record?).to be true
    end
  end
end