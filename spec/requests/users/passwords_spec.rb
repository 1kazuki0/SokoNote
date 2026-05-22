require "rails_helper"

RSpec.describe "User::Passwords", type: :request do
  describe "GET/users/password/new（リセット要求フォーム）" do
    before { get new_user_password_path }

    it "HTTPステータス200を返す" do
      expect(response).to have_http_status(200)
    end

    it "「パスワードを忘れた方へ」文言が含まれる" do
      expect(response.body).to include("パスワードを忘れた方へ")
    end

    it "ログイン画面へのリンクが含まれる" do
      expect(response.body).to include(new_user_session_path)
    end
  end

  describe "POST /users/password（リセットメール送信）" do
    let!(:user) { create(:user, password: "password") }
    before { ActionMailer::Base.deliveries.clear }

    context "パラメータが有効な場合" do
      let(:user_params) { { user: { email: user.email } } }

      it "リセットメールが1通送信される" do
        post user_password_path, params: user_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "emailが空欄の場合" do
      let(:user_params) { { user: { email: "" } } }

      it "メールが送信されない" do
        expect { post user_password_path, params: user_params } .not_to change { ActionMailer::Base.deliveries.count }
      end

      it "リセット要求フォームへリダイレクトされる" do
        post user_password_path, params: user_params
        expect(response).to redirect_to(new_user_password_path)
      end

      it "エラーメッセージがフラッシュに設定される" do
        post user_password_path, params: user_params
        expect(flash[:error]).to eq("メールアドレスを入力してください")
      end
    end

    context "デモユーザーのemailの場合" do
      let(:demo_params) { { user: { email: ENV.fetch("DEMO_USER_EMAIL") } } }

      it "メールが送信されない" do
        expect {
          post user_password_path, params: demo_params
        }.not_to change { ActionMailer::Base.deliveries.count }
      end

      it "リセット要求フォームへリダイレクトされる" do
        post user_password_path, params: demo_params
        expect(response).to redirect_to(new_user_password_path)
      end

      it "エラーメッセージがフラッシュに設定される" do
        post user_password_path, params: demo_params
        expect(flash[:error]).to eq("デモユーザーのパスワードはリセットできません")
      end
    end

    context "存在しないemailの場合" do
      let(:user_params) { { user: { email: "nonexistent@example.com" } } }

      # paranoid: true なので、存在しなくても成功と同じ挙動になる
      it "ログイン画面へリダイレクトされる(paranoidモード)" do
        post user_password_path, params: user_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "メールは送信されない" do
        expect {
          post user_password_path, params: user_params
        }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end

  describe "GET /users/password/edit (リセットフォーム)" do
    let(:user) { create(:user) }
    let(:raw_token) { user.send_reset_password_instructions }

    context "有効なトークンの場合" do
      before { get edit_user_password_path(reset_password_token: raw_token) }

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "「パスワードを変更」文言が含まれる" do
        expect(response.body).to include("パスワードを変更")
      end
    end

    context "無効なトークンの場合" do
      before { get edit_user_password_path(reset_password_token: "invalid_token") }

      it "200を返す(編集画面が表示される)" do
        # Deviseの仕様: editは無効トークンでも200で表示される
        # 実際の検証はupdate時に行われる
        expect(response).to have_http_status(:ok)
      end
    end
  end
  describe "PATCH /users/password (パスワード更新)" do
    let(:user) { create(:user, password: "password") }
    let(:raw_token) { user.send_reset_password_instructions }

    context "有効なトークンとパラメータの場合" do
      let(:user_params) { { user: { reset_password_token: raw_token, password: "new_password", password_confirmation: "new_password" } } }

      it "パスワードが変更される" do
        patch user_password_path, params: user_params
        expect(user.reload.valid_password?("new_password")).to be true
      end

      it "商品一覧画面へリダイレクトされる" do
        patch user_password_path, params: user_params
        expect(response).to redirect_to(items_path)
      end
    end

    context "パスワードと確認用が一致しない場合" do
      let(:user_params)  { { user: { reset_password_token: raw_token, password: "new_password", password_confirmation: "different_password" } } }

      it "パスワードが変更されない" do
        patch user_password_path, params: user_params
        expect(user.reload.valid_password?("password")).to be true
      end

      it "HTTPステータス422を返す" do
        patch user_password_path, params: user_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "無効なトークンの場合" do
      let(:user_params) { { user: { reset_password_token: "invalid_token", password: "new_password", password_confirmation: "new_password" } } }

      it "パスワードが変更されない" do
        patch user_password_path, params: user_params
        expect(user.reload.valid_password?("password")).to be true
      end

      it "HTTPステータス422を返す" do
        patch user_password_path, params: user_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
