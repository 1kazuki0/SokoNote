require File.expand_path(File.dirname(__FILE__) + "/environment")
ENV.each { |k, v| env(k, v) }
# 環境変数（nilの場合は開発環境)を保存
rails_env = ENV["RAILS_ENV"] || :development
# 環境を設定
set :environment, rails_env
set :output, "log/cron.log"
# 1日ごとにゲストユーザーのデータリセットを実行
every 1.day, at: "0:00 am" do
  rake "guest:reset"
end

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
