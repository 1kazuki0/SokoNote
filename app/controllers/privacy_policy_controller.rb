class PrivacyPolicyController < ApplicationController
  # トップ画面でも表示するため、ログインスキップのコールバック
  skip_before_action :authenticate_user!, only: [ :index ]

  def index; end
end
