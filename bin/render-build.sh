set -o errexit # エラーが起きたら即終了

bundle install # Gemfileに書かれている必要なgemを全部インストール
bundle exec rails assets:precompile # CSS・JavaScript を本番用にビルド
bundle exec rails assets:clean # 古いアセットファイルを削除
bundle exec rails db:migrate # データベースの構造を最新にする