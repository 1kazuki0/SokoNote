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
    @store = current_user.stores.find(params[:id])
  end

  def update
    @store = current_user.stores.find(params[:id])
    if @store.update(store_params)
      redirect_to stores_path, success: "店舗を更新しました"
    else
      flash.now[:error] = "店舗の更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @store = current_user.stores.find(params[:id])
    @store.destroy
    redirect_to stores_path, success: "店舗を削除しました"
  end

  private

  def store_params
    params.require(:store).permit(:name)
  end
end
