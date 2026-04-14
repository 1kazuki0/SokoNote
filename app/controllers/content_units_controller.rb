class ContentUnitsController < ApplicationController
  def index
    @content_units = current_user.content_units.order(:name)
  end

  def new
    @content_unit = current_user.content_units.new()
  end

  def create
    @content_unit = current_user.content_units.new(content_unit_params)
    if @content_unit.save
      redirect_to content_units_path, success: "内容量単位を登録しました"
    else
      flash.now[:error] = "内容量単位登録に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def content_unit_params
    params.require(:content_unit).permit(:name)
  end
end
