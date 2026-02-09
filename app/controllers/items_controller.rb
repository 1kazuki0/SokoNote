class ItemsController < ApplicationController
  before_action :authenticate_user!
  def index
    puts "Userモデルで使用できるメソッド#{User.methods.grep(/items/)}"
    puts "current_uesrのclassは#{current_user.class}"
    # puts "indexアクションが呼ばれているか確認"
    # puts "リクエスト情報#{params}"
    # puts "ログインユーザー確認#{current_user}"
    # puts "HTTPは#{request.method}です"
    # puts "リクエストパスは#{request.path}です"
    # puts "リクエストフルパスは#{request.fullpath}です"
    # puts "#コントローラー名は#{controller_name}です"
    # puts "#アクション名は#{action_name}です"
    # puts "#{session.to_h}"
    # puts "#{cookies.to_h}"
    # puts "#SQLを発行しました→#{Item.all.to_sql}"
    # puts "Itemの総数: #{Item.count}"
    # puts "ユーザー詳細: #{current_user.inspect}" if current_user
    # puts "許可されたパラメータ: #{params.permit(:item_id, :name).to_h}"
    # puts "使用できるメソッドを出力#{params.methods.sort}"
    # puts "レスポンスステータス: #{response.status}"
    # puts "IDの型確認: #{params[:id].class}"
    @items = current_user.items.includes(:user)
    # puts "@itemsの中身を確認#{@items.inspect}"
    # puts "@itemsのクラスを確認#{@items.class}"
    # puts "@itemsの件数を確認#{@items.count}"
  end

  def new_step1
  end

  def save_new_step1
    puts "データきてる？#{item_new_step1_params}"
    session[:item_new_step1] = item_new_step1_params
    redirect_to new_step2_items_path
  end

  def new_step2
    puts "{sessionが来ているか確認#{session.to_h}}"
  end

  def create
  end

  def show
    puts "リクエスト情報#{params}"
    @item = Item.find(params[:id])
    @purchases = @item.purchases.order(purchased_on: :desc)
    # puts "#{@purchases.inspect}"
  end

  private

  def item_new_step1_params
    params.require(:item_new_step1).permit(:item_name, :category_name, :content_quantity, :pack_quantity, :price, :tax_rate)
  end
end
