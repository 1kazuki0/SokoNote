class ItemRegistrationsController < ApplicationController
  def new
    @form = ItemRegistrationForm.new
    @items = current_user.items.order(:name)
    @content_units = current_user.content_units.order(:name)
  end

  def create
    @form = ItemRegistrationForm.new(item_registrations_params)
    @form.user = current_user
    if @form.save
      redirect_to complete_item_registration_path(item_id: @form.item.id, purchase_id: @form.purchase.id)
    else
      @items = current_user.items.order(:name)
      @content_units = current_user.content_units.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # 商品登録完了確認用の遷移アクション
  def complete
    @item = current_user.items.find_by(id: params[:item_id])
    @purchase = @item.purchases.find_by(id: params[:purchase_id])
  end

  # 前回内容量・単位の自動補完用アクション
  def last_purchase
    item = current_user.items.find_by(name: params[:name])
    last_purchase = item&.purchases&.order(purchased_on: :desc)&.first
    render json: {
      content_quantity: last_purchase&.content_quantity,
      content_unit_name: last_purchase&.content_unit&.name
    }
  end

  private

  def item_registrations_params
    params.require(:item_registrations).permit(:item_name, :content_quantity, :content_unit_name, :price, :tax_rate)
  end
end
