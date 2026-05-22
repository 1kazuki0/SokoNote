require "rails_helper"

RSpec.describe "User::Sessions", type: :request do
  describe "GET /user/sign_in（ログイン画面）" do
    context "ログインしていない場合" do
      before { get new_user_session_path }

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "root_path(top画面)へのリンクが含まれる" do
        expect(response.body).to include(root_path)
      end

      it "新規登録画面へのリンクが含まれる" do
        expect(response.body).to include(new_user_registration_path)
      end

      it "パスワードリセット画面へのリンクが含まれる" do
        expect(response.body).to include(new_user_password_path)
      end

      it "LINEログインへのリンクが含まれる" do
        expect(response.body).to include(user_line_omniauth_authorize_path)
      end

      it "ログインの文言が含まれる" do
        expect(response.body).to include(I18n.t("devise.sessions.new.sign_in"))
      end
    end

    context "ログインしている場合" do
      let(:user) { create(:user) }
      before do
        sign_in user
        get new_user_session_path
      end

      it "商品一覧画面にリダイレクトされる" do
        expect(response).to redirect_to(items_path)
      end
    end
  end

  describe "POST /user/sign_in（ログイン処理）" do
    let!(:user) { create(:user, password: "password") }

    context "パラメータが有効な場合" do
      let(:user_params) { { user: { email: user.email, password: "password" } } }
      it "商品一覧画面にリダイレクトされる" do
        post user_session_path, params: user_params
        expect(response).to redirect_to(items_path)
      end

      it "ログイン状態になる" do
        post user_session_path, params: user_params
        get items_path
        expect(response).to have_http_status(200)
      end
    end

    context "パラメータが無効な場合" do
      context "パスワードが誤り" do
        let(:user_params) { { user: { email: user.email, password: "wrong_password" } } }

        it "HTTPステータス422を返す" do
          post user_session_path, params: user_params
          expect(response).to have_http_status(422)
        end
      end

      context "emailが誤り" do
        let(:user_params) { { user: { email: "wrong@example.com", password: "password" } } }

        it "HTTPステータス422を返す" do
          post user_session_path, params: user_params
          expect(response).to have_http_status(422)
        end
      end
    end
  end

  describe "DELETE /user/sign_out（ログアウト処理）" do
    let(:user) { create(:user) }
    before do
      sign_in user
      delete destroy_user_session_path
    end

    it "root_pathにリダイレクトされる" do
      expect(response).to redirect_to(root_path)
    end

    it "ログアウト状態になる" do
      get items_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
