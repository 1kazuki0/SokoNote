class ItemRegistrationsController < ApplicationController
  def new
    @form = ItemRegistrationForm.new
  end

  def create
    @form = ItemRegistrationForm.new(item_registrations_params)
    @form.user = current_user
    if @form.save
      redirect_to items_path, success: "商品登録に成功しました"
    else
      flash.now[:error] = "商品の登録に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  private
  
  def item_registrations_params
    params.require(:item_registrations).permit(:item_name, :content_quantity, :content_unit_name, :price, :tax_rate)
  end
end
