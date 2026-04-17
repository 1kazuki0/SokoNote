class PurchasesController < ApplicationController
  def index
    @item = current_user.items.find(params[:item_id])
    @purchases = @item.purchases.includes(:store, :content_unit, :pack_unit).order(purchased_on: :desc)
    @lowest_purchase = @item.purchases.order(:unit_price).first
  end

  def edit
    @purchase = current_user.purchases.includes(:item, :store, :content_unit, :pack_unit, item: :category).find(params[:id])
    @form = PurchaseUpdateForm.new(
      category_name:      @purchase.item.category&.name,
      item_name:          @purchase.item.name,
      brand:              @purchase.brand,  
      content_quantity:   @purchase.content_quantity,
      content_unit_name:  @purchase.content_unit.name,
      pack_quantity:      @purchase.pack_quantity,
      pack_unit_name:     @purchase.pack_unit&.name,
      store_name:         @purchase.store&.name,
      purchased_on:       @purchase.purchased_on,
      price:              @purchase.price,
      tax_rate:           @purchase.tax_rate
    )
  end

  def update
    @purchase = current_user.purchases.includes(:item, :store, :content_unit, :pack_unit, item: :category).find(params[:id])
    @form = PurchaseUpdateForm.new(purchase_updates_params)
    @form.user = current_user
    @form.purchase = @purchase
    if @form.update
      puts "成功"
      redirect_to item_purchases_path(@purchase.item), success: "商品情報の詳細編集に成功しました"
    else
      puts "失敗"
      flash.now[:error] = "商品情報の編集に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    purchase = current_user.purchases.find(params[:id])
    purchase.destroy
    redirect_to purchases_path, success: "購入履歴を削除しました"
  end

  private

  def purchase_updates_params
    params.require(:purchase_updates).permit(:category_name, :item_name, :brand, :content_quantity, :content_unit_name, :pack_quantity, :pack_unit_name, :store_name, :purchased_on, :price, :tax_rate)
  end
end
