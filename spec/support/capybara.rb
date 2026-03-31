require "socket"

# :remote_chrome ドライバーを登録する
Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: "http://chrome:4444",
    options: options
  )
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV['CI']
      driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
    else
      driven_by :remote_chrome
      Capybara.server_host = "0.0.0.0"
      Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}"
    end
  end
end
