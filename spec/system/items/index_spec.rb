require 'rails_helper'

RSpec.describe "商品一覧画面", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
    sign_in user
  end

  # 商品カード（購入履歴一覧へのリンク）を特定する
  def item_card(item)
    find("a[href='#{item_purchases_path(item)}']")
  end

  describe "商品が1件も登録されていない場合" do
    before { visit items_path }

    it "商品登録を促すメッセージが表示される" do
      expect(page).to have_content("商品を登録しましょう")
    end

    it "検索フォーム・カテゴリーの絞り込みは表示されない" do
      expect(page).not_to have_field("q[name_cont]")
      expect(page).not_to have_link("全て")
    end

    it "「使い方を見てみる」から使い方画面に遷移できる" do
      click_link "使い方を見てみる"
      expect(page).to have_current_path(guide_path)
    end

    it "「商品を登録する」から商品登録画面に遷移できる" do
      click_link "商品を登録する"
      expect(page).to have_current_path(new_item_registration_path)
    end
  end

  describe "商品が登録されている場合" do
    let(:drink) { create(:category, name: "飲料", user: user) }
    let(:daily) { create(:category, name: "日用品", user: user) }
    let(:milk) { create(:item, name: "牛乳", category: drink, user: user) }
    let(:tissue) { create(:item, name: "ティッシュ", category: daily, user: user) }
    let(:egg) { create(:item, :not_category_item, name: "卵", user: user) }
    let(:store) { create(:store, name: "スーパーA", user: user) }
    let(:ml) { create(:content_unit, name: "ml", user: user) }
    let(:piece) { create(:content_unit, name: "個", user: user) }
    let(:bottle) { create(:pack_unit, name: "本", user: user) }

    before do
      # 牛乳：最安値（単価0.4円）と、それより高い購入履歴（単価0.6円）
      create(:purchase, user: user, item: milk, store: store, content_unit: ml, pack_unit: bottle,
                        content_quantity: 500, pack_quantity: 2, price: 432, tax_rate: 8)
      create(:purchase, user: user, item: milk, store: store, content_unit: ml, pack_unit: bottle,
                        content_quantity: 500, pack_quantity: 2, price: 600, tax_rate: 0)
      # 卵：店舗・単位（包装数）が未登録の購入履歴
      create(:purchase, :only_required_purchase, user: user, item: egg, content_unit: piece,
                        content_quantity: 10, pack_quantity: 1, price: 275, tax_rate: 10)
      # ティッシュ：購入履歴なし
      tissue
    end

    describe "画面表示" do
      before { visit items_path }

      it "登録済みの商品がすべて表示される" do
        expect(page).to have_content("牛乳")
        expect(page).to have_content("ティッシュ")
        expect(page).to have_content("卵")
      end

      it "他のユーザーの商品は表示されない" do
        create(:item, name: "他人の商品")
        visit items_path
        expect(page).not_to have_content("他人の商品")
      end

      it "検索フォームとカテゴリーの絞り込みが表示される" do
        expect(page).to have_field("q[name_cont]")
        expect(page).to have_link("全て")
        expect(page).to have_link("飲料")
        expect(page).to have_link("日用品")
        expect(page).to have_link("未登録")
      end

      it "商品登録ボタンが表示される" do
        expect(page).to have_link("商品登録", href: new_item_registration_path)
      end
    end

    describe "商品カード" do
      before { visit items_path }

      it "最安値の購入履歴の店舗・内容量・単価・価格・税区分が表示される" do
        within(item_card(milk)) do
          expect(page).to have_content("最安時の値段")
          expect(page).to have_content("スーパーA")
          expect(page).to have_content("500.0ml × 2本")
          expect(page).to have_content("1mlあたり 0.4円")
          expect(page).to have_content("432 円")
          expect(page).to have_content("税込8%")
          expect(page).not_to have_content("600 円")
        end
      end

      it "店舗・単位（包装数）が未登録の場合、店舗未登録と内容量のみが表示される" do
        within(item_card(egg)) do
          expect(page).to have_content("店舗未登録")
          expect(page).to have_content("10.0個")
          expect(page).not_to have_content("×")
          expect(page).to have_content("税込10%")
        end
      end

      it "購入履歴がない場合、未登録と表示される" do
        within(item_card(tissue)) do
          expect(page).to have_content("未登録")
          expect(page).not_to have_content("最安時の値段")
        end
      end

      it "クリックすると購入履歴一覧画面に遷移する" do
        item_card(milk).click
        expect(page).to have_current_path(item_purchases_path(milk))
      end
    end

    describe "商品名での検索" do
      before { visit items_path }

      it "商品名の一部で検索できる" do
        fill_in "q[name_cont]", with: "乳\n"
        expect(page).to have_content("牛乳")
        expect(page).not_to have_content("ティッシュ")
        expect(page).not_to have_content("卵")
      end

      context "該当する商品がない場合" do
        before { fill_in "q[name_cont]", with: "存在しない商品\n" }

        it "見つからなかったメッセージが表示される" do
          expect(page).to have_content("検索した結果、見つかりませんでした")
          expect(page).to have_link("商品を登録する", href: new_item_registration_path)
        end

        it "「検索条件をリセット」で全ての商品が表示される" do
          click_link "検索条件をリセット"
          expect(page).to have_current_path(items_path)
          expect(page).to have_content("牛乳")
          expect(page).to have_content("ティッシュ")
          expect(page).to have_content("卵")
        end
      end
    end

    describe "カテゴリーでの絞り込み" do
      before { visit items_path }

      it "初期表示では「全て」が選択されている" do
        expect(page).to have_link("全て", class: "bg-primary")
        expect(page).not_to have_link("飲料", class: "bg-primary")
      end

      it "カテゴリーを選択すると、そのカテゴリーの商品のみ表示される" do
        click_link "飲料"
        expect(page).to have_link("飲料", class: "bg-primary")
        expect(page).not_to have_link("全て", class: "bg-primary")
        expect(page).to have_content("牛乳")
        expect(page).not_to have_content("ティッシュ")
        expect(page).not_to have_content("卵")
      end

      it "「未登録」を選択すると、カテゴリー未登録の商品のみ表示される" do
        click_link "未登録"
        expect(page).to have_link("未登録", class: "bg-primary")
        expect(page).to have_content("卵")
        expect(page).not_to have_content("牛乳")
        expect(page).not_to have_content("ティッシュ")
      end

      it "「全て」を選択すると、全ての商品が表示される" do
        click_link "飲料"
        click_link "全て"
        expect(page).to have_link("全て", class: "bg-primary")
        expect(page).to have_content("牛乳")
        expect(page).to have_content("ティッシュ")
        expect(page).to have_content("卵")
      end
    end
  end
end
