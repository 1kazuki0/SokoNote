require 'rails_helper'

RSpec.describe "PrivacyPolicies", type: :request do
  describe "GET /index（プライバシーポリシー画面）" do
    context "ログインしていない場合" do
      before { get privacy_policy_path }

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "ログイン画面へリダイレクトされない" do
        expect(response).not_to redirect_to(new_user_session_path)
      end

      it "トップ画面にもどるリンクが含まれている" do
        expect(response.body).to include(root_path)
      end
    end

    context "ログインしている場合" do
      let(:user) { create(:user) }

      before do
        sign_in user
        get privacy_policy_path
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "設定画面にもどるリンクが含まれている" do
        expect(response.body).to include(setting_path)
      end
    end
  end
end

