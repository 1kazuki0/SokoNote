module ApplicationHelper
  def active_class(*controllers)
    controllers.include?(controller_name) ? "text-green" : "text-gray-400"
  end
end
