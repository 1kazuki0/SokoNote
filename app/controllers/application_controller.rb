class ApplicationController < ActionController::Base
  # アクション実行前にログインしているか確認
  before_action :authenticate_user!

  def after_sign_in_path_for(resources)
    items_path
  end
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  add_flash_types :success, :notice, :error
end
