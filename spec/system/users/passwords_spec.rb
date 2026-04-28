# require "rails_helper"

# RSpec.describe "UsersPasswords", type: :system do
#   let(:user) { User.create(name: "sokonote", email: "sokonote@email.com", password: "password") }
#   before do
#     visit new_user_password_path
#   end

#   describe "パスワードリセットメール送信画面" do
#     context "画面の表示" do
#       it "「SokoNote」と表示される" do
#         expect(page).to have_content("SokoNote")
#       end

#       it "「パスワードを忘れた方へ」と表示される" do
#         expect(page).to have_content("パスワードを忘れた方へ")
#       end

#       it "メールアドレスの入力欄が表示される" do
#         expect(page).to have_field("user[email]")
#       end

#       it "「再設定メールを送信」ボタンが表示される" do
#         expect(page).to have_button("再設定メールを送信")
#       end
#     end
#   end
# end
