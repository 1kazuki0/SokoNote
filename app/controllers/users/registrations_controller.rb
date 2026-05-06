# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # アクション実行前のログイン確認をスキップする
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  # 許可されたnameカラムをcreateアクションの前に受け取る
  before_action :configure_sign_up_params, only: [ :create ]
  # before_action :configure_account_update_params, only: [:update]

  # デモユーザーの更新・削除をアクション前に確認
  before_action :ensure_normal_user, only: [ :update, :destroy ]

  # GET /resource/sign_up
  # def new
  # super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # アカウント情報更新後のリダイレクトURLの設定
  def after_update_path_for(resource)
    setting_path
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  # メールアドレス変更不可に伴い、更新時のメールアドレス受け入れ不可
  def account_update_params
    params.require(:user).permit(:name, :password, :password_confirmation, :current_password)
  end

  # 変更時、パスワード欄が空でもcurrent_password不要で更新できる
  def update_resource(resource, params)
    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:current_password)
      resource.update_without_password(params.except(:current_password))
    else
      resource.update_with_password(params)
    end
  end

  # devise認証のnameカラムを許可（他のカラムはデフォルトで許可されている）
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  # 編集・削除を実装しようとした場合、設定画面にリダイレクトされる処理
  def ensure_normal_user
    if resource.demo?
      redirect_to setting_path, alert: "デモユーザー更新・削除はできません。"
    end
  end
end
