class StoresController < ApplicationController
  def index
    @stores = current_user.stores.order(:name)
  end

  def new
    @store = current_user.stores.new()
  end

  def create
    @store = current_user.stores.new(store_params)
    if @store.save
      redirect_to stores_path, success: "店舗を登録しました"
    else
      flash.now[:error] = "店舗登録に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def store_params
    params.require(:store).permit(:name)
  end
end
