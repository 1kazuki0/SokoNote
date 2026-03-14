require "rails_helper"

RSpec.describe "設定画面", type: :system do
  let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }

  before do
    driven_by(:rack_test)
    sign_in user
    visit setting_path
  end

  # ─── 画面の表示 ──────────────────────────────────────────────────────────────
  describe "画面の表示" do
    it "タイトルに「設定」と表示される" do
      expect(page).to have_content("設定")
    end

    context "アカウントセクション" do
      it "「アカウント」セクションが表示される" do
        expect(page).to have_content("アカウント")
      end

      it "「プロフィール設定」リンクが表示される" do
        expect(page).to have_link("プロフィール設定")
      end

      it "「名前、メールアドレス」の説明が表示される" do
        expect(page).to have_content("名前、メールアドレス")
      end
    end

    context "サポート＆情報セクション" do
      it "「サポート & 情報」セクションが表示される" do
        expect(page).to have_content("サポート")
        expect(page).to have_content("情報")
      end

      it "「利用規約」リンクが表示される" do
        expect(page).to have_link("利用規約")
      end

      it "「プライバシーポリシー」リンクが表示される" do
        expect(page).to have_link("プライバシーポリシー")
      end
    end

    context "ログアウトセクション" do
      it "「ログアウト」ボタンが表示される" do
        expect(page).to have_button("ログアウト")
      end
    end
  end

  # ─── ログアウト操作 ───────────────────────────────────────────────────────────
  describe "ログアウト操作" do
    it "「ログアウト」ボタンを押すとログインページに遷移する" do
      click_button "ログアウト"
      expect(current_path).to eq root_path
    end

    it "ログアウト後は認証が必要なページにアクセスできない" do
      click_button "ログアウト"
      visit items_path
      expect(current_path).to eq new_user_session_path
    end
  end
end