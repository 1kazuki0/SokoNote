# Railsの機能（モデル・コントローラー・データベース）を使うテストのための設定
# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# 環境が本番環境の場合、データベースの切り捨てを防止する
abort("The Rails environment is running in production mode!") if Rails.env.production?
# rspecファイルに`--require rails_helper`が含まれている場合は、以下を解除する
# これにより、マイグレーションがまだ実行されていないためにRailsジェネレータがクラッシュするのを防ぐ。（DBがまだ作られていない時のエラー対策）
# return unless Rails.env.test?
# RSpecとRailsを連携させるライブラリを読み込む
require 'rspec/rails'
# 追加のライブラリはこれより下に書く。

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# webdriverの設定（capybara等ファイルの読み込み設定)

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # ActiveRecordを使用していないor各例をトランザクション内で実行したくない場合は、次の行を削除するかfalseにする
  config.use_transactional_fixtures = true

  # 以下はActiveRecordサポートが完全に無効になる。
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # 利用可能な型については、features のドキュメントに記載
  # https://rspec.info/features/7-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # deviseのヘルパーメソッドをrequestsで使用できるように設定
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  # # webdriverの設定
  # config.before(:each, type: :system) do
  #   driven_by :remote_chrome
  #   Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
  #   Capybara.server_port = 4444
  #   Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
  #   Capybara.ignore_hidden_elements = false
  # end

end
