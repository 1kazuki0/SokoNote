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

  def edit
    @purchase = current_user.purchases.includes(:item, :store, item: :category).find(params[:id])
  end

  def update
    purchase = current_user.purchases.find(params[:id])
    ActiveRecord::Base.transaction do
      purchase.update!(purchase_params)
      purchase.item.update!(name: params[:item_name])
      category = current_user.categories.find_or_create_by!(name: params[:category_name])
      purchase.item.update!(category: category)
      store = current_user.stores.find_or_create_by!(name: params[:store_name])
      purchase.update!(store: store)
    end
      puts "成功 #{params.inspect}"
      redirect_to item_path(purchase.item), success: "商品の情報を更新しました"
    rescue => e
      puts "失敗"
      flash.now[:error] = "入力に問題があります"
      @purchase = current_user.purchases.includes(:item, :store, item: :category).find(params[:id])
      render :edit, status: :unprocessable_entity
  end

  def destroy
    purchase = current_user.purchases.find(params[:id])
    purchase.destroy
    redirect_to purchases_path, success: "購入履歴を削除しました"
  end

  private

  def purchase_params
    params.require(:purchase).permit(:brand, :content_quantity, :content_unit, :pack_quantity, :pack_unit, :price, :purchased_on)
  end
end
