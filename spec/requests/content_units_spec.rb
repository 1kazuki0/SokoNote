require 'rails_helper'

RSpec.describe "ContentUnits", type: :request do
  let(:user) { create(:user) }
  describe "GET /content_units（単位（内容量）一覧）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get content_units_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "単位（内容量）が0件の場合" do
        before { get content_units_path }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "「単位（内容量）がありません」が表示される" do
          expect(response.body).to include("単位（内容量）がありません")
        end

        it "単位（内容量）新規登録画面へのリンクが含まれる" do
          expect(response.body).to include(new_content_unit_path)
        end
      end

      context "単位（内容量）が1件以上ある場合" do
        let!(:content_unit1) { create(:content_unit, user: user, name: "単位（内容量）A") }
        let!(:content_unit2) { create(:content_unit, user: user, name: "単位（内容量）B") }

        before { get content_units_path }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "自分の登録した単位（内容量）名が表示される" do
          expect(response.body).to include("単位（内容量）A")
          expect(response.body).to include("単位（内容量）B")
        end

        it "編集画面へのリンクが含まれる" do
          expect(response.body).to include(edit_content_unit_path(content_unit1))
        end

        it "削除リンクが含まれる" do
          expect(response.body).to include(content_unit_path(content_unit1))
        end

        it "単位（内容量）追加ボタンのリンクが含まれる" do
          expect(response.body).to include(new_content_unit_path)
        end
      end

      context "他のユーザーの単位（内容量）がある場合" do
        let(:other_user) { create(:user) }
        let!(:other_content_unit) { create(:content_unit, user: other_user, name: "他人の単位（内容量）") }

        before { get content_units_path }

        it "他のユーザーの単位（内容量）は表示されない" do
          expect(response.body).not_to include("他人の単位（内容量）")
        end
      end
    end
  end

  describe "GET /content_units/new(新規登録画面)" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get new_content_unit_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
        get new_content_unit_path
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "「単位（内容量）登録」のタイトルが表示される" do
        expect(response.body).to include("単位（内容量）登録")
      end

      it "フォームの送信先パスが含まれる" do
        expect(response.body).to include(content_units_path)
      end
    end
  end

  describe "POST /content_units（新規登録処理）" do
    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        post content_units_path, params: { content_unit: { name: "単位（内容量）A" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "パラメータが有効な場合" do
        let(:valid_params) {  { content_unit: { name: "単位（内容量）A" } } }

        it "単位（内容量）が1件作成される" do
          expect { post content_units_path, params: valid_params }.to change(ContentUnit, :count).by(1)
        end

        it "単位（内容量）一覧画面へリダイレクトされる" do
          post content_units_path, params: valid_params
          expect(response).to redirect_to(content_units_path)
        end

        it "フラッシュメッセージが設定される" do
          post content_units_path, params: valid_params
          expect(flash[:success]).to eq("単位（内容量）を登録しました")
        end
      end

      context "パラメータが無効な場合" do
        let(:invalid_params) { { content_unit: { name: "" } } }

        it "単位（内容量）が作成されない" do
          expect { post content_units_path, params: invalid_params }.not_to change(ContentUnit, :count)
        end

        it "HTTPステータス422を返す" do
          post content_units_path, params: invalid_params
          expect(response).to have_http_status(422)
        end

        it "新規登録フォームが再表示される" do
          post content_units_path, params: invalid_params
          expect(response.body).to include("単位（内容量）登録")
        end
      end

      context "同名単位（内容量）が既に存在する場合" do
        let!(:existing_content_unit) { create(:content_unit, user: user, name: "単位（内容量）A") }
        let(:duplicate_params) { { content_unit: { name: "単位（内容量）A" } } }

        it "単位（内容量）が作成されない" do
          expect { post content_units_path, params: duplicate_params }.not_to change(ContentUnit, :count)
        end

        it "HTTPステータス422を返す" do
          post content_units_path, params: duplicate_params
          expect(response).to have_http_status(422)
        end
      end

      context "他のユーザーが同名の単位（内容量）を持っている場合" do
        let(:other_user) { create(:user) }
        let!(:other_content_unit) { create(:content_unit, user: other_user, name: "単位（内容量）A") }
        let(:valid_params) { { content_unit: { name: "単位（内容量）A" } } }

        it "同名はユーザー内のみで一意なので登録できる" do
          expect { post content_units_path, params: valid_params }.to change(ContentUnit, :count).by(1)
        end
      end
    end
  end

  describe "GET /content_units/:id/edit（編集画面）" do
    let!(:content_unit) { create(:content_unit, user: user, name: "単位（内容量）A") }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        get edit_content_unit_path(content_unit)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
        get edit_content_unit_path(content_unit)
      end

      it "HTTPステータス200を返す" do
        expect(response).to have_http_status(200)
      end

      it "「単位（内容量）編集」のタイトルが表示される" do
        expect(response.body).to include("単位（内容量）編集")
      end

      it "既存の単位（内容量）名がフォームに含まれる" do
        expect(response.body).to include('value="単位（内容量）A"')
      end
    end

    context "他のユーザーの単位（内容量）にアクセスした場合" do
      let(:other_user) { create(:user) }
      let!(:other_content_unit) { create(:content_unit, user: other_user) }
      
      before { sign_in user }

      it "HTTPステータス404を返す" do
        get edit_content_unit_path(other_content_unit)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "PATCH /content_units/:id（更新処理）" do
    let!(:content_unit) { create(:content_unit, user: user, name: "単位（内容量）A" ) }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        patch content_unit_path(content_unit), params: { content_unit: { name: "食品" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "パラメータが有効な場合" do
        let(:valid_params) { { content_unit: { name: "新しい単位（内容量）" } } }

        it "単位（内容量）名が更新される" do
          patch content_unit_path(content_unit), params: valid_params
          expect(content_unit.reload.name).to eq("新しい単位（内容量）")
        end

        it "単位（内容量）一覧画面へリダイレクトされる" do
          patch content_unit_path(content_unit), params: valid_params
          expect(response).to redirect_to(content_units_path)
        end

        it "フラッシュメッセージが設定される" do
          patch content_unit_path(content_unit), params: valid_params
          expect(flash[:success]).to eq("単位（内容量）を更新しました")
        end
      end

      context "パラメータが無効な場合" do
        let(:invalid_params) { { content_unit: { name: ""} } }

        it "更新されない" do
          patch content_unit_path(content_unit), params: invalid_params
          expect(content_unit.reload.name).to eq("単位（内容量）A")
        end

        it "HTTPステータス422を返す" do
          patch content_unit_path(content_unit), params: invalid_params
          expect(response).to have_http_status(422)
        end
      end

      context "他のユーザーの単位（内容量）を更新しようとした場合" do
        let(:other_user) { create(:user) }
        let!(:other_content_unit) { create(:content_unit, user: other_user, name: "他人の単位（内容量）") }

        it "更新されない" do
          patch content_unit_path(other_content_unit), params: { content_unit: { name: "変更" } }
          expect(other_content_unit.reload.name).to eq("他人の単位（内容量）")
        end

        it "HTTPステータス404を返す" do
          patch content_unit_path(other_content_unit), params: { content_unit: { name: "変更" } }
          expect(response).to have_http_status(404)
        end
      end
    end
  end

  describe "DELETE /content_units/:id（削除処理）" do
    let!(:content_unit) { create(:content_unit, user: user) }

    context "ログインしていない場合" do
      it "ログイン画面へリダイレクトされる" do
        delete content_unit_path(content_unit)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "削除されない" do
        expect { delete content_unit_path(content_unit) }.not_to change(ContentUnit, :count)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "単位（内容量）が1件削除される" do
        expect { delete content_unit_path(content_unit) }.to change(ContentUnit, :count).by(-1)
      end

      it "単位（内容量）一覧画面へリダイレクトされる" do
        delete content_unit_path(content_unit)
        expect(response).to redirect_to(content_units_path)
      end

      it "フラッシュメッセージが設定される" do
        delete content_unit_path(content_unit)
        expect(flash[:success]).to eq("単位（内容量）を削除しました")
      end

      context "他のユーザーの単位（内容量）を削除しようとした場合" do
        let(:other_user) { create(:user) }
        let!(:other_content_unit) { create(:content_unit, user: other_user) }

        it "削除されない" do
          expect { delete content_unit_path(other_content_unit) }.not_to change(ContentUnit, :count)
        end

        it "HTTPステータス404を返す" do
          delete content_unit_path(other_content_unit)
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
