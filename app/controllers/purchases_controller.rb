class PurchasesController < ApplicationController
    before_action :authenticate_user!
  def new_step1
    puts "リクエスト情報#{params}"
    @item = Item.find(params[:item_id])
  end

  def session
  end

  def new_step2
  end
end
