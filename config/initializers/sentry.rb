# frozen_string_literal: true

# sentry(エラー監視ツール)の設定
if defined?(Sentry)
  Sentry.init do |config|
    # どんな操作履歴を記録するかの設定
    # breadcrumbs（エラーが起きるまでの操作履歴）
    # RailsのDB操作・ビュー描画などを記録と外部へのHTTPリクエストを記録
    config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

    # どのSentryプロジェクトに送るかの設定
    config.dsn = ENV["SENTRY_DSN"]

    # 1回のリクエストの処理時間の計測を100回のうち10回にする
    # 今回は使用しないのでコメントアウトにする
    # config.traces_sample_rate = 0.1
  end
end