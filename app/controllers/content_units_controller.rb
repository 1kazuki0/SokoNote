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

  def edit
    @content_unit = current_user.content_units.find(params[:id])
  end

  def update
    @content_unit = current_user.content_units.find(params[:id])
    if @content_unit.update(content_unit_params)
      redirect_to content_units_path, success: "内容量単位を更新しました"
    else
      flash.now[:error] = "内容量単位の更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @content_unit = current_user.content_units.find(params[:id])
    if @content_unit.destroy
      redirect_to content_units_path, success: "内容量単位を削除しました", status: :see_other
    else
      redirect_to content_units_path, alert: "購入履歴があるため削除することができません", status: :see_other
    end
  end

  private

  def content_unit_params
    params.require(:content_unit).permit(:name)
  end
end
