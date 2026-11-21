require 'rails_helper'

RSpec.describe "共通レイアウト", type: :system do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }
  let(:item) { create(:item, user: user, category: category) }

  # フッターの各タブのリンク先
  let(:footer_paths) { [ items_path, new_item_registration_path, comparison_path, setting_path ] }

  before do
    driven_by(:rack_test)
  end

  # フッターのリンクはアイコン表示のため、リンク先のpathで要素を特定する
  def footer_link(path)
    find("footer a[href='#{path}']")
  end

  # トップページ（LP）には利用規約等のリンクを並べたLP専用のfooterがあるため、
  # 共通のフッターナビゲーションは商品一覧タブのリンクの有無で判定する
  def footer_nav_selector
    "footer a[href='#{items_path}']"
  end

  # 指定したタブだけが強調表示（text-primary）され、それ以外は通常表示（text-middle-gray）であることを確認する
  def expect_active_tab(active_path)
    expect(footer_link(active_path)[:class]).to include("text-primary")
    (footer_paths - [ active_path ]).each do |path|
      expect(footer_link(path)[:class]).to include("text-middle-gray")
    end
  end

  # ヘッダーの戻るボタン（arrow_backアイコンのリンク）
  def back_button
    find("header a", text: "arrow_back")
  end

  describe "フッター" do
    context "未ログインの場合" do
      it "ログイン画面でフッターが表示されない" do
        visit new_user_session_path
        expect(page).not_to have_css(footer_nav_selector)
      end
    end

    context "ログイン中の場合" do
      before do
        sign_in user
      end

      it "商品一覧画面でフッターが表示される" do
        visit items_path
        expect(page).to have_css(footer_nav_selector)
      end

      it "トップページ（LP）ではフッターが表示されない" do
        visit root_path
        expect(page).not_to have_css(footer_nav_selector)
      end

      describe "画面遷移" do
        before do
          visit setting_path
        end

        it "一覧タブから商品一覧画面に遷移できる" do
          footer_link(items_path).click
          expect(page).to have_current_path(items_path)
        end

        it "登録タブから商品登録画面に遷移できる" do
          footer_link(new_item_registration_path).click
          expect(page).to have_current_path(new_item_registration_path)
        end

        it "比較タブから商品比較画面に遷移できる" do
          footer_link(comparison_path).click
          expect(page).to have_current_path(comparison_path)
        end

        it "設定タブから設定画面に遷移できる" do
          visit items_path
          footer_link(setting_path).click
          expect(page).to have_current_path(setting_path)
        end
      end

      describe "表示中の画面に対応するタブの強調表示" do
        it "商品一覧画面では一覧タブが強調表示される" do
          visit items_path
          expect_active_tab(items_path)
        end

        it "購入履歴一覧画面では一覧タブが強調表示される" do
          visit item_purchases_path(item)
          expect_active_tab(items_path)
        end

        it "商品登録画面では登録タブが強調表示される" do
          visit new_item_registration_path
          expect_active_tab(new_item_registration_path)
        end

        it "商品比較画面では比較タブが強調表示される" do
          visit comparison_path
          expect_active_tab(comparison_path)
        end

        it "設定画面では設定タブが強調表示される" do
          visit setting_path
          expect_active_tab(setting_path)
        end

        it "カテゴリ管理画面では設定タブが強調表示される" do
          visit categories_path
          expect_active_tab(setting_path)
        end
      end
    end
  end

  describe "ヘッダー" do
    describe "SokoNoteのロゴ" do
      it "ロゴからトップページに遷移できる" do
        visit new_user_session_path
        within("header") do
          click_link "SokoNote"
        end
        expect(page).to have_current_path(root_path)
      end
    end

    describe "戻るボタン" do
      context "back_pathを指定した画面の場合" do
        it "ログイン画面では戻るボタンが表示され、トップページに遷移できる" do
          visit new_user_session_path
          back_button.click
          expect(page).to have_current_path(root_path)
        end

        it "購入履歴一覧画面では戻るボタンが表示され、商品一覧画面に遷移できる" do
          sign_in user
          visit item_purchases_path(item)
          back_button.click
          expect(page).to have_current_path(items_path)
        end
      end

      context "back_pathを指定していない画面の場合" do
        it "商品一覧画面では戻るボタンが表示されない" do
          sign_in user
          visit items_path
          expect(page).not_to have_css("header a", text: "arrow_back")
        end
      end
    end

    describe "トップページ（LP）" do
      it "未ログインの場合、ヘッダーが表示されない" do
        visit root_path
        expect(page).not_to have_css("header")
      end

      it "ログイン中の場合も、ヘッダーが表示されない" do
        sign_in user
        visit root_path
        expect(page).not_to have_css("header")
      end
    end
  end

  # フォームのエラー表示（error_messagesパーシャル）も同じ配色クラスを使うため、
  # レイアウトが出力するmain直下のフラッシュメッセージに絞って確認する
  describe "フラッシュメッセージ" do
    before do
      visit new_user_session_path
    end

    it "成功メッセージが成功用のスタイルで表示される" do
      fill_in "user_email", with: user.email
      fill_in "password-field", with: "password"
      within(".default-login") do
        click_button "ログイン"
      end
      expect(page).to have_css("main > div.bg-flash-success-bg.text-flash-success-text", text: "ログインしました。")
      expect(page).not_to have_css("main > div.bg-flash-error-bg")
    end

    it "エラーメッセージがエラー用のスタイルで表示される" do
      fill_in "user_email", with: user.email
      fill_in "password-field", with: "wrongpass"
      within(".default-login") do
        click_button "ログイン"
      end
      expect(page).to have_css("main > div.bg-flash-error-bg.text-flash-error-text", text: "メールアドレスまたはパスワードが違います。")
      expect(page).not_to have_css("main > div.bg-flash-success-bg")
    end
  end
end
