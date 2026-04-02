class ApplicationController < ActionController::Base
  # アクション実行前にログインしているか確認 
  before_action :authenticate_user!
  
  # アクション実行前にsessionを削除
  before_action :clear_new_step1_item_session
  def after_sign_in_path_for(resources)
    items_path
  end
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  add_flash_types :success, :notice, :error

  private

  # フォームオブジェクトで使用したsessionが残っていれば削除
  def clear_new_step1_item_session
    return unless session[:item_new_step1].present?
    session.delete(:item_new_step1)
  end
end
