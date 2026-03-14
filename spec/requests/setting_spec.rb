require "rails_helper"

RSpec.describe "Setting", type: :request do # モデルの存在しないcontrollerのため"Setting"で文字列指定
  let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }

  describe "GET / setting" do
    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        get setting_path
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      it "HTTPステータスコード200を返す" do
        sign_in user
        get setting_path
        expect(response).to have_http_status(200)
      end
    end
  end
end
