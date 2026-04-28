# RSpec内でFactoryBotのメソッドを簡単に使用できるようにする設定
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
