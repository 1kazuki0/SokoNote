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

  def edit
    @category = current_user.categories.find(params[:id])
  end

  def update
    @category = current_user.categories.find(params[:id])
    if @category.update(category_params)
      redirect_to categories_path, success: "カテゴリを更新しました"
    else
      flash.now[:error] = "カテゴリの更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category = current_user.categories.find(params[:id])
    @category.destroy
    redirect_to categories_path, success: "カテゴリを削除しました"
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
