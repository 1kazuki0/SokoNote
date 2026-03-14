require "rails_helper"

RSpec.describe Category, type: :model do

  let(:user) {User.create(name: "sokonote", email: "sokonote@email.com", password: "password")}

  describe "バリデーション" do
    context "無効な場合" do
      it "カテゴリー名が空であれば無効" do
        category = user.categories.new(name: nil)
        expect(category).to be_invalid
      end

      it "同じユーザーで同じカテゴリー名は無効" do
        category1 = user.categories.create(name: "sokonote")
        expect(category1).to be_valid
        category2 = user.categories.new(name: "sokonote")
        expect(category2).to be_invalid
      end
      
      it "カテゴリー名が31文字なら無効" do
        category = user.categories.new(name: "a" * 31)
        expect(category).to be_invalid
      end
    end
    
    context "有効な場合" do
      it "別ユーザーなら同じカテゴリー名でも有効" do
        user2 = User.create(name: "sokonote2", email: "sokonote2@email.com", password: "password")
        category1 = user.categories.create(name: "sokonote")
        expect(category1).to be_valid
        category2 = user2.categories.new(name: "sokonote")
        expect(category2).to be_valid
      end

      it "カテゴリー名があれば有効" do
        category = user.categories.new(name: "sokonote")
        expect(category).to be_valid
      end

      it "カテゴリー名が29文字なら有効" do
        category = user.categories.new(name: "a" * 29)
        expect(category).to be_valid
      end

      it "カテゴリーが30文字なら有効" do
        category = user.categories.new(name: "a" * 30)
        expect(category).to be_valid
      end
    end
  end
end


##### メモ #####

# 1.name: nilについて
#   モデルに記載しているバリデーションpresence: trueは内部でblank?メソッドを使用している
#   blank?メソッドは、nil,""," "をfalseをまとめてtrueにするので
#   テストは3つ（nil,""," ")で分けず、代表して1つ（nilのみ）にまとめている。