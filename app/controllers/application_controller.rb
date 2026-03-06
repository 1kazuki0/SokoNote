class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  # アクション実行前にsessionを削除
  before_action :clear_new_step1_item_session
  def after_sign_in_path_for(resources)
    items_path
  end
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  add_flash_types :success, :notice, :error


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  private

  # フォームオブジェクトで使用したsessionが残っていれば削除
  def clear_new_step1_item_session
    return unless session[:item_new_step1].present?
    session.delete(:item_new_step1)
  end
end
