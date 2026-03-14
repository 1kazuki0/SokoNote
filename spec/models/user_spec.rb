require "rails_helper"

RSpec.describe User, type: :model do
  
  describe "バリデーション" do
    
    context "無効の場合" do

      it "ユーザー名がnilであれば無効" do
        user = User.new(name: nil, email: "sokonote@email.com", password: "password")
        expect(user).to be_invalid
      end
      
      it "パスワードの文字の中に空白が含まれているのであれば無効" do
        user = User.new(name: "sokonote", email: "sokonote@email.com", password: "pass word")
        expect(user).to be_invalid
      end
    end
    
    context "有効の場合" do
      
      it "ユーザー名・メールアドレス・パスワード・確認用パスワードの一致があれば有効" do
        user = User.new(name: "sokonote", email: "sokonote@email.com", password: "password")
        expect(user).to be_valid
      end
    end
  end
end

##### メモ #####

# 1.メールアドレス・パスワードのnil,空,空白について
#  それぞれgem Deviseで保証しているバリデーションなので記載しない。

# 2.メールアドレスの重複について
#  重複もDeviseが保証しているのバリデーションなので記載しない。

# 3.パスワードの文字数制限
#  同様でDeviseが保証しているのバリデーションなので記載しない。