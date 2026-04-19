class ItemRegistrationsController < ApplicationController
  def new
    @form = ItemRegistrationForm.new
  end

  def create
    @form = ItemRegistrationForm.new(item_registrations_params)
    @form.user = current_user
    if @form.save
      redirect_to complete_item_registration_path(item_id: @form.item.id, purchase_id: @form.purchase.id)
    else
      flash.now[:error] = "商品の登録に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def complete
    @item = current_user.items.find_by(id: params[:item_id])
    @purchase = @item.purchases.find_by(id: params[:purchase_id])
  end


  private

  def item_registrations_params
    params.require(:item_registrations).permit(:item_name, :content_quantity, :content_unit_name, :price, :tax_rate)
  end
end
