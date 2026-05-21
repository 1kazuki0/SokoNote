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
  # アソシエーション
  # ============================================================
  describe "アソシエーション" do 
    let(:user) { create(:user) }  # このブロックだけ create で上書き
    
    it "categoriesをhas_manyで関連づけている" do
      association = User.reflect_on_association(:categories)
      expect(association.macro).to eq(:has_many)
    end

    it "itemsをhas_manyで関連づけている" do
      association = User.reflect_on_association(:items)
      expect(association.macro).to eq(:has_many)
    end

    it "storesをhas_manyで関連づけている" do
      association = User.reflect_on_association(:stores)
      expect(association.macro).to eq(:has_many)
    end

    it "purchasesをhas_manyで関連づけている" do
      association = User.reflect_on_association(:purchases)
      expect(association.macro).to eq(:has_many)
    end

    it "content_unitsをhas_manyで関連づけている" do
      association = User.reflect_on_association(:content_units)
      expect(association.macro).to eq(:has_many)
    end

    it "pack_unitsをhas_manyで関連づけている" do
      association = User.reflect_on_association(:pack_units)
      expect(association.macro).to eq(:has_many)
    end
  end

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

    it "userを削除するとstoresも削除される" do
      user.stores.create!(name: "〇〇スーパー大阪店")
      expect { user.destroy }.to change(Store, :count).by(-1)
    end

    it "userを削除するとpurchasesも削除される" do
      item = user.items.create!(name: "牛乳")
      content_unit = user.content_units.create!(name: "ml")
      item.purchases.create!(brand: nil, content_quantity: 1000, pack_quantity: 1, price: 200, tax_rate: 0, unit_price: 0.2, purchased_on: "2026/01/01", content_unit: content_unit, user: user)
      expect { user.destroy }.to change(Purchase, :count).by(-1)
    end

    it "userを削除するとcontent_unitsも削除される" do
      user.content_units.create!(name: "ml")
      expect { user.destroy }.to change(ContentUnit, :count).by(-1)
    end

    it "userを削除するとpack_unitsも削除される" do
      user.pack_units.create!(name: "パック")
      expect { user.destroy }. to change(PackUnit, :count).by(-1)
    end
  end

  # ============================================================
  # ビジネスロジック
  # ============================================================
  describe "ビジネスロジック" do
    describe "#line_user?" do
      context "LINEログイン経由の登録ではない場合" do
        let(:user) { create(:user) }  # このブロックだけ create で上書き
        it "falseを返す" do
          expect(user.line_user?).to be false
        end
      end
      
      context "LINEログイン経由の登録の場合" do
        let(:line_user) { create(:user, :line_user) }
        it "trueを返す" do
          expect(line_user.line_user?).to be true
        end
      end
    end

    describe "#email_required?" do
      context "LINEログイン経由の登録ではない場合" do
        let(:user) { create(:user) }  # このブロックだけ create で上書き
        it "trueを返す" do
          expect(user.email_required?).to be true
        end
      end

      context "LINEログイン経由の登録の場合" do
        let(:line_user) { create(:user, :line_user) }
        it "falseを返す" do
          expect(line_user.email_required?).to be false
        end
      end
    end

    describe "#password_required?" do
      context "LINEログイン経由の登録の場合" do
        let(:line_user) { create(:user, :line_user) }
        it "falseを返す" do
          expect(line_user.password_required?).to be false
        end

        context "通常メールアドレス登録のユーザーの場合" do
          let(:user) { create(:user) }
            
          context "新規登録時（未保存）" do
            let(:new_user) { build(:user) }
            it "trueを返す" do
              expect(new_user.password_required?).to be true
            end
          end

          context "既存ユーザーがパスワードを入力していない場合" do
            it "falseを返す" do
              user.password = nil
              user.password_confirmation = nil
              expect(user.password_required?).to be false
            end
          end

          context "既存ユーザーがパスワードを変更しようとしている場合" do
            it "trueを返す" do
              user.password = "newpassword"
              user.password_confirmation = "newpassword"
              expect(user.password_required?).to be true
            end
          end
        end
      end
    end

    describe "#demo?" do
      context "emailがデモユーザーのメールアドレスと一致する場合" do
        let(:demo_user) { create(:user, name: ENV.fetch("DEMO_USER_NAME"), email: ENV.fetch("DEMO_USER_EMAIL"), password: ENV.fetch("DEMO_USER_PASSWORD")) } # デモユーザーの作成
        it "trueを返す" do
          expect(demo_user.demo?).to be true
        end
      end
      
      context "emailがデモユーザーのメールアドレスと一致しない場合" do
        let(:user) { build(:user, email: "sample@email.com") }
        it "falseを返す" do
          expect(user.demo?).to be false
        end
      end
    end
  end
  # ============================================================
  # コールバック
  # before_update :prevent_demo_user_changes の動作確認
  # ============================================================
  describe "コールバック" do
    describe "before_update :prevent_demo_user_changes" do
      context "デモユーザーではない場合" do
        let(:user) { create(:user) }  # このブロックだけ create で上書き
        it "nameは変更することができる" do
          user.name = "名前変更"
          expect(user.save).to be true
        end
      end

      context "デモユーザーの場合" do
        let(:demo_user) { create(:user, name: ENV.fetch("DEMO_USER_NAME"), email: ENV.fetch("DEMO_USER_EMAIL"), password: ENV.fetch("DEMO_USER_PASSWORD")) } # デモユーザーの作成
        context "name,email,passwordのいずれかを変更しようとした場合" do
          it "保存に失敗してエラーメッセージを返す" do
            demo_user.name = "名前変更"
            expect(demo_user.save).to be false
          end
        end
      end
    end
  end
end