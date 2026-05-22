require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    context "ログインしていない場合" do
      before { get root_path }

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end
    
      it "ログインへのリンクが含まれる" do
        expect(response.body).to include(new_user_session_path)
      end

      it "新規登録へのリンクが含まれる" do
        expect(response.body).to include(new_user_registration_path)
      end

      it "LINE公式アカウントへのリンクが含まれる" do
        expect(response.body).to include("https://lin.ee/XIpurrj")
      end

      it "キャッチコピーが含まれる" do
        expect(response.body).to include("底値 × 単価記録・比較アプリ")
      end
    end

    context "ログインしている場合" do
      let(:user) { create(:user) }
      before do
        sign_in user
        get root_path
      end
      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end
    end
  end
end

