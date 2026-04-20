# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # アクション実行前のログイン確認をスキップする
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    email = params.dig(:user, :email)
    # メールアドレスが空白だった時の処理
    if email.blank?
      flash[:error] = "メールアドレスを入力してください"
      redirect_to new_user_password_path and return
    end

    # メールアドレスがデモユーザーだった時の処理
    if email == ENV.fetch("DEMO_USER_EMAIL", nil)
      flash[:error] = "デモユーザーのパスワードはリセットできません"
      redirect_to new_user_password_path
      return
    end
    super
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
