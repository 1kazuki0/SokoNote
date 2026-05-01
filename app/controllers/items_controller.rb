class ItemsController < ApplicationController
  def index
    @q = current_user.items.ransack(params[:q])
    @items = @q.result(distinct: true).includes(:purchases, purchases: [ :store, :content_unit, :pack_unit ])
    @has_any_items = current_user.items.exists?
    @categories = current_user.categories.order(:name)
  end

  # 商品名削除用アクション
  def destroy
    item = current_user.items.find(params[:id])
    item.destroy
    redirect_to items_path, success: "「#{item.name}」を削除しました"
  end
end
