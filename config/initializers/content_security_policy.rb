# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Content-Security-Policy（CSP）の設定
# どこから読み込んだリソースなら実行・表示してよいかをブラウザに指示
Rails.application.configure do
  config.content_security_policy do |policy| # 自分のサイト（:self)、HTTPSの外部サイト(:https）
    policy.default_src :self, :https         # 基本ルール：自分のサイトとHTTPSの外部サイトからの読み込みを許可
    policy.font_src    :self, :https, :data  # フォントの読み込み
    policy.img_src     :self, :https, :data  # 画像の読み込み
    policy.object_src  :none                 # <object>、<embed>、<applet> というHTMLタグで何かを埋め込むのを完全禁止
    policy.script_src  :self, :https         # JavaScriptの読み込み <==　XSSで最重要！！！
    policy.style_src   :self, :https         # CSSの読み込み
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end
  #
  #   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  #   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  #   config.content_security_policy_nonce_directives = %w(script-src style-src)
  #
  #  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
