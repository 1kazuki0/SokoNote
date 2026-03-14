require "rails_helper"

RSpec.describe "Home", type: :request do # モデルの存在しないcontrollerのため"Home"で文字列指定
  let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }

  describe "GET /" do
    context "ログインしていない場合" do
      it "HTTPステータス200を返す" do
        get root_path
        expect(response).to have_http_status(200)
      end
    end

    context "ログインしている場合" do
      it "HTTPステータス200を返す" do
        sign_in user
        get root_path
        expect(response).to have_http_status(200)
      end
    end
  end
end
