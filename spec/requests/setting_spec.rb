require "rails_helper"

RSpec.describe "Setting", type: :request do # モデルの存在しないcontrollerのため"Setting"で文字列指定
  let(:user) { create(:user) }

  describe "GET /setting（設定画面）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get setting_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
        get setting_path
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "「設定」のタイトルが表示される" do
        expect(response.body).to include("設定")
      end

      it "プロフィール設定へのリンクが含まれる" do
        expect(response.body).to include(edit_user_registration_path)
      end

      it "カテゴリー管理へのリンクが含まれる" do
        expect(response.body).to include(categories_path)
      end

      it "店舗管理へのリンクが含まれる" do
        expect(response.body).to include(stores_path)
      end

      it "単位（内容量）へのリンクが含まれる" do
        expect(response.body).to include(content_units_path)
      end

      it "使い方を見るへのリンクが含まれる" do
        expect(response.body).to include(guide_path)
      end

      it "利用規約へのリンクが含まれる" do
        expect(response.body).to include(terms_path)
      end

      it "プライバシーポリシーへのリンクが含まれる" do
        expect(response.body).to include(privacy_policy_path)
      end

      it "お問い合わせへのリンクが含まれる" do
        expect(response.body).to include("https://docs.google.com/forms/d/e/1FAIpQLSckG9kXNz8uKZLA1j2pEQ5W9_VSLcwqYyGZyWky0v_rzOvljg/viewform?usp=header")
      end

      it "ログアウトのリンクが含まれる" do
        expect(response.body).to include(destroy_user_session_path)
      end
    end
  end
end
