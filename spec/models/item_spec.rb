require "rails_helper"

RSpec.describe Item, type: :model do
  let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }
  let(:category) { user.categories.create(name: "食品") }

  describe "バリデーション" do
    context "無効の場合" do
      it "商品名が空白なら無効" do
        item = category.items.new(name: nil, user: user)
        expect(item).to be_invalid
      end

      it "同じカテゴリー内で同じ商品名があれば無効" do
        item1 = category.items.create(name: "ハム", user: user)
        expect(item1).to be_valid
        item2 = category.items.new(name: "ハム", user: user)
        expect(item2).to be_invalid
      end

      it "商品名の長さが31文字なら無効" do
        item = category.items.new(name: "a" * 31, user: user)
        expect(item).to be_invalid
      end
    end

    context "有効の場合" do
      it "商品名があれば有効" do
        item = category.items.new(name: "ハム", user: user)
        expect(item).to be_valid
      end

      it "別のカテゴリーで同じ商品名があるのは有効" do
        item = category.items.create(name: "ハム", user: user)
        expect(item).to be_valid
        category2 = user.categories.create(name: "肉", user: user)
        item2 = category2.items.new(name: "ハム", user: user)
        expect(item2).to be_valid
      end

      it "商品名の長さが30文字なら有効" do
        item = category.items.new(name: "a" * 30, user: user)
        expect(item).to be_valid
      end

      it "商品名の長さが29文字なら有効" do
        item = category.items.new(name: "a" * 29, user: user)
        expect(item).to be_valid
      end
    end
  end
end
