require 'rails_helper'

RSpec.describe "パスワードリセットメール送信画面", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
    visit new_user_password_path
  end

  describe "画面表示" do
    it "見出しが表示される" do
      expect(page).to have_content("パスワードを忘れた方へ")
    end

    it "メールアドレス入力欄が表示される" do
      expect(page).to have_field("メールアドレス")
    end

    it "送信ボタンが表示される" do
      expect(page).to have_button("再設定メールを送信")
    end

    it "ログイン画面に戻るリンクが表示される" do
      expect(page).to have_link("ログイン画面に戻る")
    end
  end

  describe "フォーム送信" do
    context "登録済みメールアドレスを入力した場合" do
      it "完了メッセージが表示される" do
        fill_in "メールアドレス", with: user.email
        click_button "再設定メールを送信"
        expect(page).to have_content("パスワード再設定メールを送信しました")
      end
    end

    context "未登録のメールアドレスを入力した場合" do
      it "登録済みと同じ完了メッセージが表示される（セキュリティ仕様）" do
        fill_in "メールアドレス", with: "notfound@example.com"
        click_button "再設定メールを送信"
        expect(page).to have_content("パスワード再設定メールを送信しました")
      end
    end

    context "メールアドレスを未入力で送信した場合" do
      it "エラーメッセージが表示される" do
        click_button "再設定メールを送信"
        expect(page).to have_content("メールアドレスを入力してください")
      end
    end
  end

  describe "画面遷移" do
    it "ログイン画面に戻るリンクをクリックするとログイン画面に遷移する" do
      click_link "ログイン画面に戻る"
      expect(current_path).to eq new_user_session_path
    end
  end
end
