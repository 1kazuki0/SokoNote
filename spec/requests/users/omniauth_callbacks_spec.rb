require "rails_helper"

RSpec.describe "User::OmniauthCallbacks", type: :request do
  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:line] = nil
  end

  describe "GET/POST /users/auth/line/callback（LINEログイン処理）" do
    context "認証成功 + 名前あり" do
      before do
        OmniAuth.config.mock_auth[:line] = OmniAuth::AuthHash.new(provider: "line", uid: "UID1234567890", info: { name: "テストユーザー" })
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:line]
      end

      context "新規ユーザーの場合" do
        it "ユーザーが1件作成される" do
          expect { post user_line_omniauth_callback_path }.to change(User, :count).by(1)
        end

        it "LINEから取得した名前で作成される" do
          post user_line_omniauth_callback_path
          expect(User.last.name).to eq("テストユーザー")
        end

        it "providerとuidが保存される" do
          post user_line_omniauth_callback_path
          expect(User.last.provider).to eq("line")
          expect(User.last.uid).to eq("UID1234567890")
        end

        it "商品一覧画面へリダイレクトされる" do
          post user_line_omniauth_callback_path
          expect(response).to redirect_to(items_path)
        end

        it "フラッシュメッセージが設定される" do
          post user_line_omniauth_callback_path
          expect(flash[:notice]).to eq("LINEでログインしました")
        end
      end

      context "既存ユーザーの場合" do
        let!(:existing_user) { create(:user, :line_user, uid: "UID1234567890", name: "既存ユーザー") }

        it "新規作成されない" do
          expect { post user_line_omniauth_callback_path }.not_to change(User, :count)
        end

        it "既存ユーザーの名前は変更されない" do
          post user_line_omniauth_callback_path
          expect(existing_user.reload.name).to eq("既存ユーザー")
        end

        it "商品一覧画面へリダイレクトされる" do
          post user_line_omniauth_callback_path
          expect(existing_user.reload.name).to eq("既存ユーザー")
        end

        it "商品一覧画面へリダイレクトされる" do
          post user_line_omniauth_callback_path
          expect(response).to redirect_to(items_path)
        end
      end
    end

    context "認証成功 + 名前なし" do
      before do
        OmniAuth.config.mock_auth[:line] = OmniAuth::AuthHash.new(
          provider: "line",
          uid: "U9999999999",
          info: { name: nil }
        )
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:line]
      end

      it "デフォルト名「LINEユーザー」で作成される" do
        post user_line_omniauth_callback_path
        expect(User.last.name).to eq("LINEユーザー")
      end
    end
  end
end
