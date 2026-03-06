class ComparisonController < ApplicationController
  before_action :authenticate_user!
  def index
    puts "パラメータ詳細#{params.inspect}"
    puts "sessionの確認#{session.inspect}"

    # 購入履歴（最安値）からデータがパラメータに存在するときのみ実行、それ以外は処理を終了させる
    return unless params[:purchase_id].present?
    # パラメータから取得した購入履歴（最安値）を取得
    @purchase = current_user.purchases.find(params[:purchase_id])

    puts "変数データの確認#{@purchase.inspect}"
  end
end
