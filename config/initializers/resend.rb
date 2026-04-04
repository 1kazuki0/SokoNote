# Resendのgemを読み込み
require "resend"
Resend.configure do |config|
  config.api_key = ENV["RESEND_API_KEY"]
end
