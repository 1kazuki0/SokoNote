class ItemsController < ApplicationController
  def index
    @q = current_user.items.ransack(params[:q])
    @items = @q.result(distinct: true).includes(:category, :purchases, purchases: [ :store, :content_unit, :pack_unit ])
    @has_any_items = current_user.items.exists?
    @categories = current_user.categories.order(:name)
  end
end
