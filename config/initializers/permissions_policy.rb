# Be sure to restart your server when you modify this file.

# Define an application-wide HTTP permissions policy. For further
# information see: https://developers.google.com/web/updates/2018/06/feature-policy

# ブラウザの強い機能をこのアプリで使わせるかどうかの指示
Rails.application.config.permissions_policy do |policy|
  policy.camera      :none                                # カメラへのアクセスオフ
  policy.gyroscope   :none                                # スマホの回転を検知するセンサーオフ
  policy.microphone  :none                                # 音声入力オフ
  policy.usb         :none                                # web USB API厳禁（ブラウザからUSB機器に直接アクセスできる仕組み）
  policy.payment     :none # "https://secure.example.com" # ブラウザ統合の決済UIを呼び出す仕組みオフ
  policy.geolocation :none                                # 【追加】位置情報取得オフ
  policy.fullscreen  :self                                # このサイト自身だけフルスクリーンOK
end
