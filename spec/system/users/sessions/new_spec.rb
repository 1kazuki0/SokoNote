require 'rails_helper'

RSpec.describe "ログイン画面", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
    visit new_user_session_path
  end

  # パスワード欄はビューで id: "password-field" が指定されているためid指定で入力
  def fill_in_form(email:, password:)
    fill_in "user_email", with: email
    fill_in "password-field", with: password
  end

  describe "画面表示" do
    it "見出しが表示される" do
      expect(page).to have_content("ログイン")
    end

    it "各入力欄が表示される" do
      expect(page).to have_field("user_email")
      expect(page).to have_field("password-field")
    end

    it "次回自動ログインのチェックボックスが表示される" do
      expect(page).to have_field("user_remember_me")
    end

    it "ログインボタンが表示される" do
      expect(page).to have_button("ログイン")
    end

    it "LINEでログインボタンが表示される" do
      expect(page).to have_button("LINEでログイン")
    end

    it "新規登録画面に遷移するリンクが表示される" do
      expect(page).to have_link("アカウントをお持ちでない方はこちら")
    end

    it "パスワードリセット画面に遷移するリンクが表示される" do
      expect(page).to have_link("パスワードを忘れましたか？")
    end
  end

  describe "ログイン" do
    context "入力値が正常な場合" do
      it "ログインに成功する" do
        fill_in_form(email: user.email, password: "password")
        within(".default-login") do
          click_button "ログイン"
        end
        expect(page).to have_content("ログインしました。")
      end
    end

    context "メールアドレスが誤っている場合" do
      it "ログインに失敗しエラーメッセージが表示される" do
        fill_in_form(email: "wrong@example.com", password: "password")
        within(".default-login") do
          click_button "ログイン"
        end
        expect(page).to have_content("メールアドレスまたはパスワードが違います。")
        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context "パスワードが誤っている場合" do
      it "ログインに失敗しエラーメッセージが表示される" do
        fill_in_form(email: user.email, password: "wrongpass")
        within(".default-login") do
          click_button "ログイン"
        end
        expect(page).to have_content("メールアドレスまたはパスワードが違います。")
        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context "未入力の場合" do
      it "ログインに失敗しエラーメッセージが表示される" do
        fill_in_form(email: "", password: "")
        within(".default-login") do
          click_button "ログイン"
        end
        expect(page).to have_content("メールアドレスまたはパスワードが違います。")
      end
    end
  end

  describe "画面遷移" do
    it "新規登録画面に遷移できる" do
      click_link "アカウントをお持ちでない方はこちら"
      expect(page).to have_current_path(new_user_registration_path)
    end

    it "パスワードリセット画面に遷移できる" do
      click_link "パスワードを忘れましたか？"
      expect(page).to have_current_path(new_user_password_path)
    end
  end
end
