class PurchasesController < ApplicationController
    before_action :authenticate_user!

  def edit
    puts "パラメータ詳細#{params.inspect}"
    puts "sessionの確認#{session.inspect}"
    @purchase = current_user.purchases.includes(:item, :store, item: :category).find(params[:id])
    @form = PurchaseForm.new(
      item_name:        @purchase.item.name,
      category_name:    @purchase.item.category.name,
      brand:            @purchase.brand,
      store:            @purchase.store.name,
      content_quantity: @purchase.content_quantity,
      content_unit:     @purchase.content_unit,
      pack_quantity:    @purchase.pack_quantity,
      pack_unit:        @purchase.pack_unit,
      price:            @purchase.price,
      tax_rate:         @purchase.tax_rate,
      purchased_on:     @purchase.purchased_on
    )
  end

  def update
    @purchase = current_user.purchases.includes(:item, :store, item: :category).find(params[:id])
    @form = PurchaseForm.new(purchase_params)
    if @form.valid?
      begin
        ActiveRecord::Base.transaction do
          @purchase.item.category.update!(name: @form.category_name)
          @purchase.item.update!(name: @form.item_name)
          @purchase.store.update!(name: @form.store)
          @purchase.update!(
            brand: @form.brand,
            content_quantity: @form.content_quantity,
            content_unit: @form.content_unit,
            pack_quantity: @form.pack_quantity,
            pack_unit: @form.pack_unit,
            price: @form.price,
            tax_rate: @form.tax_rate,
            purchased_on: @form.purchased_on,
            unit_price: @form.set_unit_price
          )
        end
          redirect_to item_path(@purchase.item), success: "商品の情報を更新しました"
      rescue => e
          @purchase = current_user.purchases.includes(:item, :store, item: :category).find(params[:id])
          flash.now[:error] = "不具合です入力に問題があります"
          render :edit, status: :unprocessable_entity
      end
    else
      flash.now[:error] = "入力に問題があります"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    purchase = current_user.purchases.find(params[:id])
    purchase.destroy
    redirect_to purchases_path, success: "購入履歴を削除しました"
  end

  private

  def purchase_params
    params.require(:purchase_form).permit(:item_name, :category_name, :brand, :store, :content_quantity, :content_unit, :pack_quantity, :pack_unit, :price, :tax_rate, :purchased_on)
  end
end
