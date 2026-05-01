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
    if item.purchases.exists?
      redirect_to item_purchases_path(item), error: "購入履歴がある商品は削除できません"
    elsif item.destroy
      redirect_to items_path, success: "「#{item.name}」を削除しました"
    else
      redirect_to item_purchases_path(item), error: "商品の削除に失敗しました"
    end
  end
end
