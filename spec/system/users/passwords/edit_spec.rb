require 'rails_helper'

RSpec.describe "パスワードリセット画面", type: :system do
  let(:user) { create(:user) }
  let(:token) { user.send(:set_reset_password_token) }

  before do
    driven_by(:rack_test)
    visit edit_user_password_path(reset_password_token: token)
  end

  def fill_in_form(password:, password_confirmation: nil)
    fill_in "user_password", with: password
    fill_in "user_password_confirmation", with: password_confirmation || password
  end

  def submit_form
    within "form[action='#{user_password_path}']" do
      click_button
    end
  end

  describe "画面表示" do
    it "見出しが表示される" do
      expect(page).to have_content("パスワードを変更")
    end

    it "各入力欄が表示される" do
      expect(page).to have_field("user_password")
      expect(page).to have_field("user_password_confirmation")
    end

    it "変更ボタンが表示される" do
      expect(page).to have_button("パスワードを変更する")
    end

    it "ログイン画面に戻るリンクが表示される" do
      expect(page).to have_link("ログイン画面に戻る", href: new_user_session_path)
    end
  end

  describe "パスワード変更" do
    context "入力値が正常な場合" do
      it "変更に成功し新しいパスワードでログインできる" do
        fill_in_form(password: "newpassword")
        submit_form
        expect(page).to have_content("パスワードが正しく変更されました。")
        expect(user.reload.valid_password?("newpassword")).to be true
      end
    end

    context "パスワードが未入力の場合" do
      it "変更に失敗しエラーメッセージが表示される" do
        fill_in_form(password: "")
        submit_form
        expect(page).to have_content("パスワードの変更に失敗しました")
      end
    end

    context "パスワードが6文字未満の場合" do
      it "変更に失敗しエラーメッセージが表示される" do
        fill_in_form(password: "pass1")
        submit_form
        expect(page).to have_content("パスワードの変更に失敗しました")
      end
    end

    context "パスワードに空白が含まれる場合" do
      it "変更に失敗しエラーメッセージが表示される" do
        fill_in_form(password: "pass word")
        submit_form
        expect(page).to have_content("は空白があると登録ができません")
      end
    end

    context "パスワードと確認用が一致しない場合" do
      it "変更に失敗しエラーメッセージが表示される" do
        fill_in_form(password: "newpassword", password_confirmation: "different")
        submit_form
        expect(page).to have_content("パスワードの変更に失敗しました")
      end
    end

    context "トークンが無効な場合" do
      it "変更に失敗しエラーメッセージが表示される" do
        visit edit_user_password_path(reset_password_token: "invalid_token")
        fill_in_form(password: "newpassword")
        submit_form
        expect(page).to have_content("パスワードの変更に失敗しました")
        expect(user.reload.valid_password?("newpassword")).to be false
      end
    end
  end

  describe "画面遷移" do
    it "ログイン画面に遷移できる" do
      click_link "ログイン画面に戻る"
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
