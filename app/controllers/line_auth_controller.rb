class LineAuthController < ApplicationController
  skip_before_action :authenticate_user!

  # LINEのアクセストークンを発行するときのURL
  LINE_TOKEN_URL = "https://api.line.me/oauth2/v2.1/token"
  # LINEのIDトークンを検証するときのURL
  LINE_TOKEN_VERIFY_URL = "https://api.line.me/oauth2/v2.1/verify"

  # ユーザーがLINEログインボタンをクリックしたときに必須のクエリパラメータを付けてリダイレクトさせる記述
  def authorize
    # CSRF対策のstateとリプレイ攻撃対策のnonceにランダム英数字付与
    state = SecureRandom.hex(24)
    nonce = SecureRandom.hex(24)

    # callback時確認のために、sessionに保存
    session[:line_oauth_state] = state
    session[:line_oauth_nonce] = nonce

    # LINEへのリダイレクト時に付与するクエリパラメータの準備
    query = { response_type: "code", client_id: ENV["LINE_CHANNEL_ID"], redirect_uri: line_callback_url, state: state, scope: "profile openid", nonce: nonce }

    # リダイレクト時のURL
    redirect_to "https://access.line.me/oauth2/v2.1/authorize?#{query.to_query}", allow_other_host: true # 外部URLのリダイレクトで例外対策
  end

  def callback
    # stateとnonceのトークンを再利用しないよう削除、session.deleteは削除すると同時に、削除した値を返すメソッド
    expected_state = session.delete(:line_oauth_state)
    expected_nonce = session.delete(:line_oauth_nonce)

    # エラーがあれば、errorのクエリが付属されるので、alertメッセージを返して処理を終了する
    if params[:error].present?
      redirect_to new_user_session_path, alert: "LINEログインをキャンセルしました"
      return
    end

    # 生成したstateとLINEからコールバックしたstateが一致しているか確認
    if expected_state.blank? || expected_state != params[:state]
      redirect_to new_user_session_path, alert: "LINEログインに失敗しました"
      return
    end

    # 取得した認可コードをトークンと交換
    token_response = exchange_code_for_token(params[:code])
    # レスポンスに失敗した時に、ログイン画面にリダイレクトさせ処理を終了する
    unless token_response.success?
      redirect_to new_user_session_path, alert: "LINEログインに失敗しました"
      return
    end

    # JSON形式のレスポンスをRubyのハッシュに変換
    token_data = JSON.parse(token_response.body)
    # レスポンスのうち、id_token（IDトークン）の値を保存
    id_token = token_data["id_token"]

    # IDトークンで検証した結果をpayloadに保存
    payload = verify_id_token(id_token, expected_nonce)
    
    # payloadがnilの場合、ログイン画面にリダイレクト
    if payload.nil?
      redirect_to new_user_session_path, alert: "LINEログインに失敗しました"
      return
    end

    # uidカラムとnameカラムをレスポンス結果（payload）から取得
    uid = payload["sub"]
    name = payload["name"].presence || "LINEユーザー"

    user = User.from_line(uid: uid, name: name)
    sign_in user
    redirect_to items_path, notice: "LINEでログインしました"
  end

  private

  # アクセストークンおよびIDトークンを発行するためにLINEにリクエストを送り、レスポンスを返す処理
  def exchange_code_for_token(code)
    Faraday.post(LINE_TOKEN_URL) do |request|
      request.headers["Content-Type"] = "application/x-www-form-urlencoded"
      request.body = URI.encode_www_form(
        grant_type: "authorization_code",
        code: code,
        redirect_uri: line_callback_url,
        client_id: ENV.fetch("LINE_CHANNEL_ID"),
        client_secret: ENV.fetch("LINE_CHANNEL_SECRET")
      )
    end
  end

  # IDトークンを検証するための処理（verify API）
  def verify_id_token(id_token, expected_nonce)
    response = Faraday.post(LINE_TOKEN_VERIFY_URL) do |request|
      request.headers["Content-Type"] = "application/x-www-form-urlencoded"
      request.body = URI.encode_www_form(
        id_token: id_token,
        client_id: ENV.fetch("LINE_CHANNEL_ID"),
        nonce: expected_nonce
      )
    end
    return nil unless response.success?
    JSON.parse(response.body)
  end
end
