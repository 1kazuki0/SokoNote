require 'rails_helper'

RSpec.describe "ユーザー新規登録画面", type: :system do
  let(:user) { build(:user) }

  before do
    driven_by(:rack_test)
    visit new_user_registration_path
  end

  def fill_in_form(name: user.name, email: user.email, password: "password", password_confirmation: nil)
    fill_in "user_name", with: name
    fill_in "user_email", with: email
    fill_in "user_password", with: password
    fill_in "user_password_confirmation", with: password_confirmation || password
  end

  describe "画面表示" do
    it "見出しが表示される" do
      expect(page).to have_content("新規アカウント登録")
    end

    it "各入力欄が表示される" do
      expect(page).to have_field("user_name")
      expect(page).to have_field("user_email")
      expect(page).to have_field("user_password")
      expect(page).to have_field("user_password_confirmation")
    end

    it "利用規約・プライバシーポリシーのリンクが表示される" do
      expect(page).to have_link("利用規約", href: terms_path)
      expect(page).to have_link("プライバシーポリシー", href: privacy_policy_path)
    end

    it "アカウント登録ボタンが表示される" do
      expect(page).to have_button("新規アカウント登録")
    end

    it "LINEで新規登録ボタンが表示される" do
      expect(page).to have_button("LINEで新規登録")
    end

    it "ログイン画面に遷移するリンクが表示される" do
      expect(page).to have_link("アカウントをお持ちの方はこちら")
    end
  end

  describe "アカウント登録" do
    context "入力値が正常な場合" do
      it "登録に成功し完了メッセージが表示される" do
        fill_in_form
        check "agreement"
        expect {
          click_button "新規アカウント登録"
          expect(page).to have_content("アカウント登録が完了しました。")
        }.to change(User, :count).by(1)
      end
    end

    context "ニックネームが未入力の場合" do
      it "登録に失敗しエラーメッセージが表示される" do
        fill_in_form(name: "")
        check "agreement"
        expect {
          click_button "新規アカウント登録"
        }.not_to change(User, :count)
        expect(page).to have_content("アカウントの登録に失敗しました")
      end
    end

    context "メールアドレスが未入力の場合" do
      it "登録に失敗しエラーメッセージが表示される" do
        fill_in_form(email: "")
        check "agreement"
        expect {
          click_button "新規アカウント登録"
        }.not_to change(User, :count)
        expect(page).to have_content("アカウントの登録に失敗しました")
      end
    end

    context "メールアドレスが登録済みの場合" do
      let!(:existing_user) { create(:user) }

      it "登録に失敗しエラーメッセージが表示される" do
        fill_in_form(email: existing_user.email)
        check "agreement"
        expect {
          click_button "新規アカウント登録"
        }.not_to change(User, :count)
        expect(page).to have_content("アカウントの登録に失敗しました")
        expect(page).to have_content("は現在使用できません")
      end
    end

    context "パスワードが6文字未満の場合" do
      it "登録に失敗しエラーメッセージが表示される" do
        fill_in_form(password: "pass1")
        check "agreement"
        expect {
          click_button "新規アカウント登録"
        }.not_to change(User, :count)
        expect(page).to have_content("アカウントの登録に失敗しました")
      end
    end

    context "パスワードに空白が含まれる場合" do
      it "登録に失敗しエラーメッセージが表示される" do
        fill_in_form(password: "pass word")
        check "agreement"
        expect {
          click_button "新規アカウント登録"
        }.not_to change(User, :count)
        expect(page).to have_content("は空白があると登録ができません")
      end
    end

    context "パスワードと確認用が一致しない場合" do
      it "登録に失敗しエラーメッセージが表示される" do
        fill_in_form(password: "password", password_confirmation: "different")
        check "agreement"
        expect {
          click_button "新規アカウント登録"
        }.not_to change(User, :count)
        expect(page).to have_content("アカウントの登録に失敗しました")
      end
    end
  end

  describe "画面遷移" do
    it "ログイン画面に遷移できる" do
      click_link "アカウントをお持ちの方はこちら"
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
