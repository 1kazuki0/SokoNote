require "rails_helper"

RSpec.describe "Home", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "ホーム画面の表示" do
    it "ログインボタンと新規登録ボタンが表示される" do
      visit root_path
      expect(page).to have_link("ログイン")
      expect(page).to have_link("新規登録")
    end

  describe "ログインボタン" do
    it "クリックするとログイン画面に遷移する" do
      visit root_path
      click_link "ログイン"
      expect(current_path).to eq new_user_session_path
    end
  end

  describe "新規登録ボタン" do
      it "クリックすると新規登録画面に遷移する" do
        visit root_path
        click_link "新規登録"
        expect(current_path).to eq new_user_registration_path
      end
    end
  end
end
