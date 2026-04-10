class CategoriesController < ApplicationController
  def index
    @categories = current_user.categories.order(:name)
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
