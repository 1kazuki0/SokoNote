class ItemsController < ApplicationController
  def index
    @items = current_user.items.includes(:category, :purchases, purchases: [ :store, :content_unit, :pack_unit ])
  end
end
