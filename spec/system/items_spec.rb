require "rails_helper"

RSpec.describe "Item", type: :system do
  let(:user)     { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }
  let(:category) { user.categories.create(name: "食品") }
  let(:store)    { user.stores.create(name: "スーパー大阪店") }
  let(:item)     { category.items.create(name: "ハム", user: user) }

  before do
    driven_by(:rack_test)
    sign_in user
  end

  # ─── 商品一覧画面 ────────────────────────────────────────────────────────────
  describe "商品一覧画面の表示" do
    context "ヘッダー" do
      it "タイトルに「底値商品一覧」と表示される" do
        visit items_path
        expect(page).to have_content "底値商品一覧"
      end
    end

    context "データがない時" do
      it "「商品を登録する」ボタンが表示される" do
        visit items_path
        expect(page).to have_link "商品を登録する"
      end

      it "「データがありません」のメッセージが表示される" do
        visit items_path
        expect(page).to have_content "データがありません"
      end

      it "「商品登録」ボタンが表示されない" do
        visit items_path
        expect(page).not_to have_link "商品登録"
      end
    end

    context "itemはあるが、purchaseが1件もない時" do
      before { item }
      it "内容量・価格欄に「未登録」と表示される" do
        visit items_path
        expect(page).to have_content "未登録"
      end
    end

    context "データがある時" do
      let(:purchase) { item.purchases.create(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: "3", pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2026/03/13", user: user, store: store) }
      before { purchase } # letは遅延で作成される。左記で各テスト前にpurchaseが作成され、連鎖してitem,category,storeも全部作成される

      context "商品カード" do
        it "商品名が表示される" do
          visit items_path
          expect(page).to have_content "ハム"
        end

        it "店舗名が表示される" do
          visit items_path
          expect(page).to have_content "スーパー大阪店"
        end

        it "最安単価が表示される" do
          visit items_path
          expect(page).to have_content "1枚 あたり： 14.0 円"
        end

        it "内容量が表示される" do
          visit items_path
          expect(page).to have_content "3パック×5枚 ¥210"
        end

        it "クリックすると購入履歴一覧画面に遷移する" do
          visit items_path
          click_link "ハム"
          expect(current_path).to eq item_path(item)
        end
      end

      context "商品登録ボタン" do
        it "表示される" do
          visit items_path
          expect(page).to have_link "商品登録"
        end

        it "商品登録画面step1に遷移する" do
          visit items_path
          click_link "商品登録"
          expect(current_path).to eq new_step1_items_path
        end
      end
    end

    context "データはあるがunit_priceがnilの時" do
      let(:purchase_unit_price) { item.purchases.create(brand: "日本ハム", content_quantity: 5, content_unit: "枚", pack_quantity: "3", pack_unit: "パック", price: 210, unit_price: nil, tax_rate: 0, purchased_on: "2026/03/13", user: user, store: store) }
      before { purchase_unit_price }
      it "最安単価に「未登録」と表示される" do
        visit items_path
        expect(page).to have_content "未登録"
      end
    end

    context "データはあるがcontent_unitがない時" do
      let(:purchase_content_unit) { item.purchases.create(brand: "日本ハム", content_quantity: 5, content_unit: nil, pack_quantity: "3", pack_unit: "パック", price: 210, unit_price: 14, tax_rate: 0, purchased_on: "2026/03/13", user: user, store: store) }
      before { purchase_content_unit }
      it "単位に「単位」と表示される" do
        visit items_path
        expect(page).to have_content "単位"
      end
    end
  end

  # ─── 商品新規登録画面 Step1 ──────────────────────────────────────────────────
  describe "商品新規登録画面 Step1" do
    before { visit new_step1_items_path }

    context "画面の表示" do
      it "「商品情報の登録 2-1」と表示される" do
        expect(page).to have_content("商品情報の登録 2-1")
      end

      it "商品名の入力欄が表示される" do
        expect(page).to have_field("item_new_step1[item_name]")
      end

      it "カテゴリ名の入力欄が表示される" do
        expect(page).to have_field("item_new_step1[category_name]")
      end

      it "内容量の入力欄が表示される" do
        expect(page).to have_field("item_new_step1[content_quantity]")
      end

      it "パック数の入力欄が表示される" do
        expect(page).to have_field("item_new_step1[pack_quantity]")
      end

      it "金額の入力欄が表示される" do
        expect(page).to have_field("item_new_step1[price]")
      end

      it "税率の選択肢が3つ表示される（税抜・8%・10%）" do
        expect(page).to have_content("税抜")
        expect(page).to have_content("8%")
        expect(page).to have_content("10%")
      end

      it "デフォルトで「税抜」が選択されている" do
        expect(page).to have_checked_field("tax-none")
      end

      it "「内容を確認して次へ」ボタンが表示される" do
        expect(page).to have_button("内容を確認して次へ")
      end
    end

    context "プレースホルダーの表示" do
      it "商品名のプレースホルダーが表示される" do
        expect(page).to have_field("item_new_step1[item_name]", placeholder: "例：牛乳 / 箱ティッシュ")
      end

      it "カテゴリ名のプレースホルダーが表示される" do
        expect(page).to have_field("item_new_step1[category_name]", placeholder: "例：飲料 / 日用品")
      end

      it "金額のプレースホルダーが表示される" do
        expect(page).to have_field("item_new_step1[price]", placeholder: "例：298 / 1200")
      end
    end

    context "税率の選択" do
      it "「8%」を選択できる" do
        choose "tax-8"
        expect(page).to have_checked_field("tax-8")
      end

      it "「10%」を選択できる" do
        choose "tax-10"
        expect(page).to have_checked_field("tax-10")
      end
    end

    context "必要な項目をすべて入力して送信した場合" do
      before do
        fill_in "item_new_step1[item_name]",        with: "牛乳"
        fill_in "item_new_step1[category_name]",    with: "飲料"
        fill_in "item_new_step1[content_quantity]",  with: 200
        fill_in "item_new_step1[pack_quantity]",     with: 1
        fill_in "item_new_step1[price]",             with: 198
        click_button "内容を確認して次へ"
      end

      it "次のステップに遷移する" do
        expect(current_path).to eq new_step2_items_path
      end
    end

    context "商品名を入力せずに送信した場合" do
      before do
        fill_in "item_new_step1[category_name]",   with: "飲料"
        fill_in "item_new_step1[content_quantity]", with: 200
        fill_in "item_new_step1[pack_quantity]",    with: 1
        fill_in "item_new_step1[price]",            with: 198
        click_button "内容を確認して次へ"
      end

      it "エラーメッセージが表示される" do
        expect(page).to have_css("div", text: /エラー|error|blank|入力/i)
      end

      it "登録画面に留まる" do
        expect(current_path).to eq save_new_step1_items_path
      end
    end
  end

  # ─── 商品新規登録画面 Step2 ──────────────────────────────────────────────────
  describe "商品新規登録画面 Step2" do
    # Step1を送信してStep2に遷移する共通処理
    before do
      visit new_step1_items_path
      fill_in "item_new_step1[item_name]",        with: "牛乳"
      fill_in "item_new_step1[category_name]",    with: "飲料"
      fill_in "item_new_step1[content_quantity]",  with: 200
      fill_in "item_new_step1[pack_quantity]",     with: 1
      fill_in "item_new_step1[price]",             with: 198
      click_button "内容を確認して次へ"
    end

    context "画面の表示" do
      it "「その他情報の登録」と表示される" do
        expect(page).to have_content("その他情報の登録")
      end

      it "「入力済みの情報」カードが表示される" do
        expect(page).to have_content("入力済みの情報")
      end
    end

    context "入力済みの情報カード（Step1の内容の確認）" do
      it "商品名が表示される" do
        expect(page).to have_content("牛乳")
      end

      it "カテゴリ名が表示される" do
        expect(page).to have_content("飲料")
      end

      it "価格が表示される" do
        expect(page).to have_content("¥198")
      end

      it "税率0の場合「税抜」と表示される" do
        expect(page).to have_content("税抜")
      end

      it "内容量が表示される" do
        expect(page).to have_content("200")
      end

      it "パック数が表示される" do
        expect(page).to have_content("1")
      end
    end

    context "税率8%でStep1を送信した場合" do
      before do
        visit new_step1_items_path
        fill_in "item_new_step1[item_name]",        with: "お茶"
        fill_in "item_new_step1[category_name]",    with: "飲料"
        fill_in "item_new_step1[content_quantity]",  with: 350
        fill_in "item_new_step1[pack_quantity]",     with: 24
        fill_in "item_new_step1[price]",             with: 980
        choose "tax-8"
        click_button "内容を確認して次へ"
      end

      it "「税込8%」と表示される" do
        expect(page).to have_content("税込8%")
      end
    end

    context "フォームの表示" do
      it "メーカー名の入力欄が表示される" do
        expect(page).to have_field("item_new_step2[brand]")
      end

      it "店舗名の入力欄が表示される" do
        expect(page).to have_field("item_new_step2[store]")
      end

      it "単位／内容量の入力欄が表示される" do
        expect(page).to have_field("item_new_step2[content_unit]")
      end

      it "単位／パック数の入力欄が表示される" do
        expect(page).to have_field("item_new_step2[pack_unit]")
      end

      it "登録日の入力欄が表示される" do
        expect(page).to have_field("item_new_step2[purchased_on]")
      end

      it "登録日のデフォルトが今日の日付になっている" do
        expect(page).to have_field("item_new_step2[purchased_on]", with: Date.today.to_s)
      end

      it "「この内容で登録する」ボタンが表示される" do
        expect(page).to have_button("この内容で登録する")
      end
    end

    context "プレースホルダーの表示" do
      it "メーカー名のプレースホルダーが表示される" do
        expect(page).to have_field("item_new_step2[brand]", placeholder: "例：伊藤園 / アタック")
      end

      it "店舗名のプレースホルダーが表示される" do
        expect(page).to have_field("item_new_step2[store]", placeholder: "例：〇〇スーパー〇〇店 / 〇〇薬局")
      end

      it "単位／内容量のプレースホルダーが表示される" do
        expect(page).to have_field("item_new_step2[content_unit]", placeholder: "例：ml、g、枚、本 など")
      end

      it "単位／パック数のプレースホルダーが表示される" do
        expect(page).to have_field("item_new_step2[pack_unit]", placeholder: "パック、箱、袋 など")
      end
    end

    context "必要な項目をすべて入力して登録した場合" do
      before do
        fill_in "item_new_step2[brand]",        with: "明治"
        fill_in "item_new_step2[store]",         with: "スーパー大阪店"
        fill_in "item_new_step2[content_unit]",  with: "ml"
        fill_in "item_new_step2[pack_unit]",     with: "本"
        click_button "この内容で登録する"
      end

      it "登録後に商品一覧画面に遷移する" do
        expect(current_path).to eq items_path
      end
    end

    context "任意項目をすべて空のまま送信した場合" do
      before { click_button "この内容で登録する" }

      it "そのまま登録されて商品一覧画面に遷移する" do
        expect(current_path).to eq items_path
      end

      it "登録完了メッセージが表示される" do
        expect(page).to have_content("商品が登録されました")
      end
    end
  end

  # ─── 商品詳細画面 ────────────────────────────────────────────────────────────
  describe "商品詳細画面の表示" do
    context "ヘッダー" do
      it "タイトルに「購入履歴一覧」と表示される" do
        visit item_path(item)
        expect(page).to have_content "購入履歴一覧"
      end

      it "「←」のリンクが表示されている" do
        visit item_path(item)
        expect(page).to have_link "arrow_back"
      end

      context "「←」のリンクを押すと" do
        before do
          driven_by ENV['CI'] ? :selenium_chrome_headless : :remote_chrome
        end
        it "商品一覧画面に遷移する" do
          visit items_path
          visit item_path(item)
          click_link "arrow_back"
          expect(page).to have_current_path(items_path, wait: 5)
        end
      end
    end

    context "購入履歴がない場合" do
      before { visit item_path(item) }

      it "商品名が表示される" do
        expect(page).to have_content("ハム")
      end

      it "カテゴリ名が表示される" do
        expect(page).to have_content("食品")
      end

      it "現在の最安単価カードが表示されない" do
        expect(page).not_to have_content("現在の最安単価")
      end

      it "「この商品で比較します」リンクが表示されない" do
        expect(page).not_to have_link("この商品で比較します")
      end

      it "全0件と表示される" do
        expect(page).to have_content("全 0 件")
      end
    end

    context "購入履歴がある場合" do
      let!(:purchase) do
        item.purchases.create(
          brand:            "日本ハム",
          content_quantity: 5,
          content_unit:     "枚",
          pack_quantity:    "3",
          pack_unit:        "パック",
          price:            210,
          unit_price:       14,
          tax_rate:         0,
          purchased_on:     "2026/03/13",
          user:             user,
          store:            store
        )
      end

      before { visit item_path(item) }

      context "現在の最安単価カード" do
        it "カードが表示される" do
          expect(page).to have_content("現在の最安単価")
        end

        it "単価が表示される" do
          expect(page).to have_content("14")
        end

        it "単位が表示される（1枚あたり）" do
          expect(page).to have_content("1枚あたり")
        end

        it "「この商品で比較します」リンクが表示される" do
          expect(page).to have_link("この商品で比較します")
        end

        it "「この商品で比較します」クリックで comparison_path に遷移する" do
          click_link "この商品で比較します"
          expect(page).to have_current_path(comparison_path, ignore_query: true)
        end

        it "「この商品で比較します」リンクに purchase_id が付与されている" do
          link = find_link("この商品で比較します")
          expect(link[:href]).to include("purchase_id=#{purchase.id}")
        end
      end

      context "購入履歴一覧" do
        it "全1件と表示される" do
          expect(page).to have_content("全 1 件")
        end

        it "購入日が表示される" do
          expect(page).to have_content("2026-03-13")
        end

        it "店舗名が表示される" do
          expect(page).to have_content("スーパー大阪店")
        end

        it "ブランドが表示される" do
          expect(page).to have_content("日本ハム")
        end

        it "容量が表示される" do
          expect(page).to have_content("5枚")
        end

        it "パック数が表示される" do
          expect(page).to have_content("3パック")
        end

        it "合計金額が表示される" do
          expect(page).to have_content("210円")
        end

        it "税率0の場合「税抜」と表示される" do
          expect(page).to have_content("税抜")
        end

        it "単価が表示される" do
          expect(page).to have_content("14")
        end

        it "最安値バッジが表示される" do
          expect(page).to have_content("最安値")
        end

        it "「編集」リンクが表示される" do
          expect(page).to have_link("編集", href: edit_purchase_path(purchase))
        end

        it "「削除」リンクが表示される" do
          expect(page).to have_link("削除", href: purchase_path(purchase))
        end
      end

      context "購入履歴が複数ある場合" do
        let!(:purchase_expensive) do
          item.purchases.create(
            brand:            "プリマハム",
            content_quantity: 5,
            content_unit:     "枚",
            pack_quantity:    "3",
            pack_unit:        "パック",
            price:            300,
            unit_price:       20,
            tax_rate:         8,
            purchased_on:     "2026/03/01",
            user:             user,
            store:            store
          )
        end

        before { visit item_path(item) }

        it "全2件と表示される" do
          expect(page).to have_content("全 2 件")
        end

        it "最安値の履歴（日本ハム）に「最安値」バッジが表示される" do
          within(find(:css, ".bg-white.rounded-2xl.shadow-sm", text: "日本ハム")) do
            expect(page).to have_content("最安値")
          end
        end

        it "高い方の履歴（プリマハム）に「最安値」バッジが表示されない" do
          within(find(:css, ".bg-white.rounded-2xl.shadow-sm", text: "プリマハム")) do
            expect(page).not_to have_content("最安値")
          end
        end

        it "税率8%の場合「8%」と表示される" do
          within(find(:css, ".bg-white.rounded-2xl.shadow-sm", text: "プリマハム")) do
            expect(page).to have_content("8%")
          end
        end

        it "「この商品で比較します」リンクに最安値のpurchase_idが付与されている" do
          link = find_link("この商品で比較します")
          expect(link[:href]).to include("purchase_id=#{purchase.id}")
        end
      end

      context "削除操作" do
        before do
          driven_by ENV['CI'] ? :selenium_chrome_headless : :remote_chrome
          sign_in user
          visit item_path(item)
        end

        it "削除後に該当の購入履歴が消える" do
          accept_confirm { click_link "削除" }
          expect(page).not_to have_content("日本ハム", wait: 5)
          expect(page).to have_content("全 0 件")
        end
      end
    end
  end
end
