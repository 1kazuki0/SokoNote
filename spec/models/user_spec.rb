require 'rails_helper'

RSpec.describe User, type: :model do
  # factory_botを参照
  let(:user) { build(:user) }

  describe "バリデーション" do
    # ============================================================
    # 通常(メール登録)ユーザー
    # ============================================================
    context "メール登録ユーザーの場合" do
      it "全ての項目が正しく入力されていれば有効" do
        expect(user).to be_valid
      end

      # --- name ---
      describe "name" do
        it "空だと無効" do
          user.name = ""
          expect(user).to be_invalid
          expect(user.errors[:name]).to include("を入力してください")
        end

        it "nilだと無効" do
          user.name = nil
          expect(user).to be_invalid
          expect(user.errors[:name]).to include("を入力してください")
        end
      end

      # --- email ---
      describe "email" do
        it "空だと無効" do
          user.email = ""
          expect(user).to be_invalid
          expect(user.errors[:email]).to include("を入力してください")
        end

        it "メール形式でないと無効" do
          user.email = "invalid_email"
          expect(user).to be_invalid
          expect(user.errors[:email]).to include("は不正な値です")
        end

        it "重複すると無効" do
          create(:user, email: "sample@example.com")
          user.email = "sample@example.com"
          expect(user).to be_invalid
          expect(user.errors[:email]).to include("は現在使用できません")
        end
      end

      # --- password ---
      describe "password" do
        it "空だと無効" do
          user.password = ""
          user.password_confirmation = ""
          expect(user).to be_invalid
          expect(user.errors[:password]).to include("を入力してください")
        end

        it "空白を含むと無効(独自バリデーション)" do
          user.password = "pass word"
          user.password_confirmation = "pass word"
          expect(user).to be_invalid
          expect(user.errors[:password]).to include("は空白があると登録ができません")
        end

        it "6文字未満だと無効" do
          user.password = "abcde"
          user.password_confirmation = "abcde"
          expect(user).to be_invalid
          expect(user.errors[:password]).to include("は6文字以上で入力してください")
        end

        it "passwordとpassword_confirmationが一致しないと無効" do
          user.password = "password1"
          user.password_confirmation = "password2"
          expect(user).to be_invalid
          expect(user.errors[:password_confirmation]).to include("とパスワードの入力が一致しません")
        end
      end

      # --- provider ---
      describe "provider" do
        it "'line'以外の値だと無効" do
          user.provider = "google"
          expect(user).to be_invalid
          expect(user.errors[:provider]).to include("は一覧にありません")
        end

        it "nilなら有効(メール登録ユーザーはproviderがnil)" do
          user.provider = nil
          expect(user).to be_valid
        end
      end
    end

    # ============================================================
    # LINE登録ユーザー
    # ============================================================
    context "LINE登録ユーザーの場合" do
      let(:line_user) { build(:user, :line_user) }

      it "全ての項目が正しく入力されていれば有効" do
        expect(line_user).to be_valid
      end

      # --- email ---
      describe "email" do
        it "nilでも有効(LINEユーザーはemail不要)" do
          line_user.email = nil
          expect(line_user).to be_valid
        end

        it "他のLINEユーザーと同じemail(nil)でも重複エラーにならない" do
          create(:user, :line_user)
          expect(line_user).to be_valid
        end
      end

      # --- password ---
      describe "password" do
        it "nilでも有効(LINEユーザーはpassword不要)" do
          line_user.password = nil
          line_user.password_confirmation = nil
          expect(line_user).to be_valid
        end

        it "空白を含むpasswordでも有効(LINEユーザーはスキップされる)" do
          line_user.password = "pass word"
          expect(line_user).to be_valid
        end
      end

      # --- provider ---
      describe "provider" do
        it "nilだと無効(email/password必須扱いになるため)" do
          line_user.provider = nil
          expect(line_user).to be_invalid
        end
      end

      # --- uid ---
      describe "uid" do
        it "空だと無効" do
          line_user.uid = ""
          expect(line_user).to be_invalid
          expect(line_user.errors[:uid]).to include("を入力してください")
        end

        it "nilだと無効" do
          line_user.uid = nil
          expect(line_user).to be_invalid
          expect(line_user.errors[:uid]).to include("を入力してください")
        end

        it "同じprovider内で重複すると無効" do
          create(:user, :line_user, uid: "test1_uid")
          line_user.uid = "test1_uid"
          expect(line_user).to be_invalid
          expect(line_user.errors[:uid]).to include("はすでに存在します")
        end
      end
    end
  end

  # ============================================================
  # アソシエーション (dependent: :destroy)
  # ============================================================
  describe "アソシエーション (dependent: :destroy)" do
    let(:user) { create(:user) }  # このブロックだけ create で上書き

    it "userを削除するとcategoriesも削除される" do
      user.categories.create!(name: "食品")
      expect { user.destroy }.to change(Category, :count).by(-1)
    end

    it "userを削除するとitemsも削除される" do
      user.items.create!(name: "牛乳")
      expect { user.destroy }.to change(Item, :count).by(-1)
    end
  end
end
