class PurchasesController < ApplicationController
    before_action :authenticate_user!
  def new_step1
    puts "リクエスト情報#{params}"
    @item = Item.find(params[:item_id])
  end

  def session
  end

  def new_step2
  end

  def destroy
    purchase = current_user.purchases.find(params[:id])
    purchase.destroy
    redirect_to purchases_path, notice: "購入履歴を削除しました"
  end
end
