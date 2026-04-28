# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # LINE認証後にLINE側から戻ってきた時のアクション
  def line
    auth = request.env["omniauth.auth"] # authにデータ（ハッシュ）を格納
      # providerカラム・uidカラムをUserから探して取得orなければ新たに作成。作成の場合、Userオブジェクトをuに格納
      user = User.find_or_create_by(provider: auth.provider, uid: auth.uid) do |u|
        u.name = auth.info.name.presence || "LINEユーザー" # ハッシュのnameをUserオブジェクトのnameに保存（新規作成時のみ）。名前がなければデフォルト値設定
      end
      # UserオブジェクトがDBに保存できなかった場合、新規登録画面にリダイレクトし処理を終了させる。
      unless user.persisted?
        redirect_to new_user_registration_path, alert: "LINEログインに失敗しました"
        return
      end

      # userでログインして商品一覧ページにリダイレクト
      sign_in(:user, user)
      redirect_to items_path, notice: "LINEでログインしました"
  end
  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
