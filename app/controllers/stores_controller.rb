class StoresController < ApplicationController
  def index
    @stores = current_user.stores.order(:name)
  end
  
  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
