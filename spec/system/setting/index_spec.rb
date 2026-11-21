require 'rails_helper'

RSpec.describe "設定画面", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
    sign_in user
    visit setting_path
  end

  describe "マスタ管理画面への遷移" do
    it "カテゴリー管理画面に遷移できる" do
      click_link "カテゴリー管理"
      expect(page).to have_current_path(categories_path)
      expect(page).to have_content("カテゴリー一覧")
    end

    it "店舗管理画面に遷移できる" do
      click_link "店舗管理"
      expect(page).to have_current_path(stores_path)
      expect(page).to have_content("店舗一覧")
    end

    it "単位（内容量）管理画面に遷移できる" do
      click_link "単位（内容量）管理"
      expect(page).to have_current_path(content_units_path)
      expect(page).to have_content("単位（内容量）一覧")
    end
  end

  describe "マスタ管理画面からの戻り" do
    it "各マスタ管理画面の戻るボタンから設定画面に戻れる" do
      [ categories_path, stores_path, content_units_path ].each do |path|
        visit path
        find("header a", text: "arrow_back").click
        expect(page).to have_current_path(setting_path)
      end
    end
  end
end
