require "rails_helper"

RSpec.describe "Items", type: :request do
  let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }

  describe "GET /items" do
    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        get items_path
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      it "HTTPステータスコード200を返す" do
        sign_in user
        get items_path
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET /new_step1_items" do
    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        get new_step1_items_path
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      it "HTTPステータスコード200を返す" do
        sign_in user
        get new_step1_items_path
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "POST /save_new_step1_items" do
    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        post save_new_step1_items_path
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      context "無効なデータの場合" do
        it "new_step1にrenderする" do
          sign_in user
          post save_new_step1_items_path, params: { item_new_step1: { item_name: nil } }
          expect(response).to have_http_status(422)
        end
      end

      context "有効なデータの場合" do
        it "new_step2にリダイレクトされる" do
          sign_in user
          post save_new_step1_items_path, params: { item_new_step1: { item_name: "ハム", category_name: "食品", content_quantity: 5, pack_quantity: 3, price: 210, tax_rate: 0, unit_price: 14 } }
          expect(response).to redirect_to new_step2_items_path
        end
      end
    end
  end

  describe "GET /new_step2_items" do
    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        get new_step2_items_path
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      context "new_step1のsessionデータがない場合" do
        it "new_step1_items_pathにリダイレクトされる" do
          sign_in user
          get new_step2_items_path
          expect(response).to redirect_to new_step1_items_path
        end
      end

      context "new_step1のsessionデータがある場合" do
        it "HTTPステータスコード200を返す" do
          sign_in user
          post save_new_step1_items_path, params: { item_new_step1: { item_name: "ハム", category_name: "食品", content_quantity: 5, pack_quantity: 3, price: 210, tax_rate: 0, unit_price: 14 } }
          get new_step2_items_path
          expect(response).to have_http_status(200)
        end
      end
    end
  end
  describe "POST /items" do
    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        post items_path
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
        post save_new_step1_items_path, params: { item_new_step1: { item_name: "ハム", category_name: "食品", content_quantity: 5, pack_quantity: 3, price: 210, tax_rate: 0, unit_price: 14 } }
      end

      context "バリデーションエラーの場合" do
        it "new_step2_items_pathにrenderされる" do
          post items_path, params: { item_new_step2: { store: "スーパー大阪店", brand: "日本ハム", content_unit: "枚", pack_unit: "パック", purchased_on: nil } }
          expect(response).to have_http_status(422)
        end
      end

      context "必要な値が入力された場合" do
        it "items_pathにリダイレクトされる" do
          post items_path, params: { item_new_step2: { store: "スーパー大阪店", brand: "日本ハム", content_unit: "枚", pack_unit: "パック", purchased_on: "2026/3/12" } }
          expect(response).to redirect_to items_path
        end
      end
    end
  end

  describe "GET /items/1" do
    let(:category) { user.categories.create(name: "食品") }
    let(:item) { category.items.create(name: "ハム", user: user) }
    context "ログインしていない場合" do
      it "ログイン画面にリダイレクトされる" do
        get item_path(item)
        expect(response).to have_http_status(302)
      end
    end

    context "ログインしている場合" do
      it "HTTPステータスコード200を返す" do
        sign_in user
        get item_path(item)
        expect(response).to have_http_status(200)
      end
    end

    context "他のユーザーのitemの場合" do
      let(:other_user) { User.create(name: "other", email: "other@email.com", password: "password") }
      let(:other_category) { other_user.categories.create(name: "食品") }
      let(:other_item) { other_category.items.create(name: "ハム", user: other_user) }
      it "HTTPステータスコード404を返す" do
        sign_in user
        get item_path(other_item)
        expect(response).to have_http_status(404)
      end
    end
  end
end
