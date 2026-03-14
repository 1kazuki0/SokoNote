class ComparisonController < ApplicationController
  before_action :authenticate_user!
  def index
    # 購入履歴（最安値）からデータがパラメータに存在するときのみ実行、それ以外は処理を終了させる
    if params[:purchase_id].present?
      # パラメータから取得した購入履歴（最安値）を取得
      @purchase_a = current_user.purchases.find(params[:purchase_id])
    else
      @purchase_a = Purchase.new
    end

    @purchase_b = Purchase.new
  end
end
