require "rails_helper"

RSpec.describe "Home", type: :request do # モデルの存在しないcontrollerのため"Home"で文字列指定
  # factory_botを参照
  let(:user) { build(:user) }

  describe "GET /" do
    it "ログインしていない場合、HTTPステータス200を返す" do
      get root_path
      expect(response).to have_http_status(200)
    end

    it "ログインしている場合も、HTTPステータス200を返す" do
      sign_in create(:user)
      get root_path
      expect(response).to have_http_status(200)
    end

      it "ページが正しくレンダリングされる" do
        get root_path
        expect(response.body).to include("底値 × 単価記録・比較アプリ")
    end
  end
end
