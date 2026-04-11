class CategoriesController < ApplicationController
  def index
    @categories = current_user.categories.order(:name)
  end

  def new
    @category = current_user.categories.new()
  end

  def create
    @category = current_user.categories.new(category_params)
    if @category.save
      redirect_to categories_path, success: "カテゴリを登録しました"
    else
      flash.now[:error] = "カテゴリ登録に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
