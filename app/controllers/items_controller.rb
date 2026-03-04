class ItemsController < ApplicationController
  before_action :authenticate_user!
  def index
    puts "Userモデルで使用できるメソッド#{User.methods.grep(/items/)}"
    puts "current_userのclassは#{current_user.class}"
    @items = current_user.items.includes(:category, :purchases, purchases: :store)
  end

  def new_step1
    @form = ItemStep1Form.new
  end

  def save_new_step1
    @form = ItemStep1Form.new(item_new_step1_params.merge(user_id: current_user.id))
    if @form.valid?
      @form.category_record
      @form.item_record
      @form.set_unit_price
      session[:item_new_step1] = @form.attributes
      redirect_to new_step2_items_path
    else
      flash.now[:error] = "商品登録に失敗しました"
      render :new_step1, status: :unprocessable_entity
    end
  end

  def new_step2
    @form = ItemStep2Form.new
    @step1_data = session[:item_new_step1]
  end

  def create
    @form = ItemStep2Form.new(item_new_step2_params.merge(user_id: current_user.id))
    unless @form.valid?
      flash.now[:error] = "入力に問題があります"
      @step1_data = session[:item_new_step1]
      render :new_step2, status: :unprocessable_entity
      return
    end
    step1 = session[:item_new_step1]
    step2 = item_new_step2_params
    merge = step2.merge(step1)
    puts "mergeしたあとのsession[:item_new_step1]の中身は？#{session.inspect}"
    ActiveRecord::Base.transaction do
      category = current_user.categories.find_or_create_by!(
        name: merge[:category_name]
      )

      store = current_user.stores.find_or_create_by!(
        name: merge[:store]
      )

      item = current_user.items.find_or_create_by!(
        category: category,
        name: merge[:item_name]
      )

      item.purchases.create!(
        user: current_user,
        item: item,
        store: store,
        brand: merge[:brand],
        content_quantity: merge[:content_quantity],
        pack_quantity: merge[:pack_quantity],
        price: merge[:price],
        tax_rate: merge[:tax_rate],
        content_unit: merge[:content_unit],
        pack_unit: merge[:pack_unit],
        unit_price: merge[:unit_price],
        purchased_on: merge[:purchased_on]
      )
    end
    session.delete(:item_new_step1)
    redirect_to items_path, success: "商品が登録されました"
    rescue ActiveRecord::RecordInvalid => e
      @step1_data = session[:item_new_step1]
      flash.now[:error] = "商品登録に失敗しました"
      render :new_step2, status: :unprocessable_entity
  end

  def show
    @item = current_user.items.find(params[:id])
    @purchases = @item.purchases.order(purchased_on: :desc)
    @lowest_purchase = @item.purchases.order(:unit_price).first
  end

  private

  def item_new_step1_params
    params.require(:item_new_step1).permit(:item_name, :category_name, :content_quantity, :pack_quantity, :price, :tax_rate)
  end

  def item_new_step2_params
    params.require(:item_new_step2).permit(:brand, :store, :content_unit, :pack_unit, :purchased_on)
  end
end
