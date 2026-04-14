class ContentUnitsController < ApplicationController
  def index
    @content_units = current_user.content_units.order(:name)
  end
end
