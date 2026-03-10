module ApplicationHelper
  def active_class(*controllers)
    controllers.include?(controller_name) ? "text-primary" : "text-middle-gray"
  end
end
