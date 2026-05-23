require 'rails_helper'

RSpec.describe "Guides", type: :request do
  describe "GET /index（使い方画面）" do
    context "ログインしていない場合" do
      before { get guide_path }

      it "ログイン画面へリダイレクトされる" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        sign_in user
        get guide_path
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "設定画面にもどるリンクが含まれている" do
        expect(response.body).to include(setting_path)
      end

      it "商品登録画面へのリンクが含まれる" do
        expect(response.body).to include(item_registration_path)
      end

      it "比較画面へのリンクが含まれている" do
        expect(response.body).to include(comparison_path)
      end
    end
  end
end
