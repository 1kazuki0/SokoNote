require "rails_helper"

RSpec.describe "Comparison", type: :request do # モデルの存在しないcontrollerのため"Comparison"で文字列指定
  let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }

  describe "GET / comparison" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get comparison_path
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      it "HTTPステータスコード200を返す" do
        sign_in user
        get comparison_path
        expect(response).to have_http_status(200)
      end

      it "わざと失敗するテスト" do
        expect(1).to eq 2
      end
    end
  end
end
