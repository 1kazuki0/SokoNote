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
      redirect_to categories_path, success: "カテゴリーを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @category = current_user.categories.find(params[:id])
  end

  def update
    @category = current_user.categories.find(params[:id])
    if @category.update(category_params)
      redirect_to categories_path, success: "カテゴリーを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category = current_user.categories.find(params[:id])
    @category.destroy
    redirect_to categories_path, success: "カテゴリーを削除しました", status: :see_other
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
