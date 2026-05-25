class ApplicationController < ActionController::Base
  # アクション実行前にログインしているか確認
  before_action :authenticate_user!
  # セキュリティヘッダーのpermissions_policyの事前処理
  before_action :set_permissions_policy_header

  def after_sign_in_path_for(resources)
    items_path
  end
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  add_flash_types :success, :notice, :error

  # configに設定しているpermissions_policyがfeature-policyに変換されるため
  # controllerにて直接設定（セキュリティヘッダー）
  def set_permissions_policy_header
    response.headers["Permissions-Policy"] ="camera=(), gyroscope=(), microphone=(), usb=(), payment=(), geolocation=(), fullscreen=(self)"
  end
end
