# require "rails_helper"

# RSpec.describe "User", type: :request do
#   let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }
#   let(:token) { user.send_reset_password_instructions }

#   describe "GET /users/password/new" do
#     context "ログインしていない場合" do
#       it "HTTPステータスコード200を返す" do
#         get new_user_password_path
#         expect(response).to have_http_status(200)
#       end
#     end

#     context "ログインしている場合" do
#       it "商品一覧画面にリダイレクトされる" do
#         sign_in user
#         get new_user_password_path
#         expect(response).to redirect_to items_path
#       end
#     end
#   end

#   describe "POST /users/password" do
#     context "ログインしていない場合" do
#       context "無効なデータ(空白）の場合" do
#         it "パスワード再設定画面へリダイレクトされる" do
#           post user_password_path, params: { user: { email: nil } }
#           expect(response).to redirect_to new_user_password_path
#         end
#       end

#       context "登録されていないメールアドレスの場合" do
#         it "セキュリティ上のためログイン画面へリダイレクトされる" do
#           post user_password_path, params: { user: { email: "free_address@email.com" } }
#           expect(response).to redirect_to new_user_session_path
#         end
#       end

#       context "有効なデータの場合" do
#         it "ログイン画面へリダイレクトされる" do
#           post user_password_path, params: { user: { email: "sokonote@email.com" } }
#           expect(response).to redirect_to new_user_session_path
#         end
#       end
#     end

#     context "ログインしている場合" do
#       it "商品一覧画面にリダイレクトされる" do
#         sign_in user
#         post user_password_path
#         expect(response).to redirect_to items_path
#       end
#     end
#   end

#   describe "GET /users/password/edit" do
#     context "ログインしていない場合" do
#       it "HTTPステータスコード200を返す" do
#         get edit_user_password_path(reset_password_token: token)
#         expect(response).to have_http_status(200)
#       end
#     end

#     context "ログインしている場合" do
#       it "商品一覧画面にリダイレクトされる" do
#         sign_in user
#         get edit_user_password_path(reset_password_token: token)
#         expect(response).to redirect_to items_path
#       end
#     end
#   end

#   describe "PUT /users/password" do
#     context "ログインしていない場合" do
#       context "無効な値の場合" do
#         it "user_password_pathにrenderされる" do
#           put user_password_path, params: { user: { password: nil, password_confirmation: nil, reset_password_token: token } }
#           expect(response).to have_http_status(422)
#         end
#       end
#     end

#     context "ログインしている場合" do
#       it "商品一覧画面にリダイレクトされる" do
#         sign_in user
#         put user_password_path
#         expect(response).to redirect_to items_path
#       end
#     end
#   end
# end
