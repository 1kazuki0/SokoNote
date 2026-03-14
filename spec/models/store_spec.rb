require "rails_helper"

RSpec.describe Store, type: :model do

  let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password")}

  describe "バリデーション" do

    context "無効の場合" do

      it "同じユーザーで同じ店舗名は無効" do
        store1 = user.stores.create(name: "sokonote")
        expect(store1).to be_valid
        store2 = user.stores.new(name: "sokonote")
        expect(store2).to be_invalid
      end

      it "店舗名が51文字なら無効" do
        store = user.stores.new(name: "a" * 51)
        expect(store).to be_invalid
      end
    end

    context "有効の場合" do

      it "店舗名が50文字なら有効" do
        store = user.stores.new(name: "a" * 50)
        expect(store).to be_valid
      end

      it "店舗名が49文字なら有効" do
        store = user.stores.new(name: "a" * 49)
        expect(store).to be_valid
      end

      it "別ユーザーなら同じ店舗名でも有効" do
        user2 = User.create(name: "sokonote2", email: "sokonote2@email.com", password: "password")
        store1 = user.stores.new(name: "sokonote")
        expect(store1).to be_valid
        store2 = user2.stores.new(name: "sokonote")
        expect(store2).to be_valid
      end

      it "店舗名があれば有効" do
        store = user.stores.new(name: "sokonote")
        expect(store).to be_valid
      end
    end
  end
end

##### メモ #####

# 1.nameカラムの空白の場合について
#   フォームオブジェクト（ItemStep2Form）で4モデルをまとめて登録。
#   store_recordメソッドでstore.blank?の場合はnilを返すことで
#   Storeモデルにpresence: trueは設定していないため、テストも記載していない。
