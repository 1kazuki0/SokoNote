require "rails_helper"

RSpec.describe "LineAuth", type: :request do
  # LINE APIのエンドポイント定数（実装と同じ）
  LINE_TOKEN_URL        = "https://api.line.me/oauth2/v2.1/token"
  LINE_TOKEN_VERIFY_URL = "https://api.line.me/oauth2/v2.1/verify"

  # 環境変数のスタブ（テスト時は固定値）
  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("LINE_CHANNEL_ID").and_return("test_channel_id")
    allow(ENV).to receive(:fetch).with("LINE_CHANNEL_SECRET").and_return("test_channel_secret")
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("LINE_CHANNEL_ID").and_return("test_channel_id")
  end

  describe "GET /users/auth/line" do
    it "LINEの認証画面へリダイレクトする" do
      get line_auth_path
      expect(response).to have_http_status(:redirect)
    end

    it "stateがsessionに保存される" do
      get line_auth_path
      expect(session[:line_oauth_state]).to be_present
    end

    it "nonceがsessionに保存される" do
      get line_auth_path
      expect(session[:line_oauth_nonce]).to be_present
    end

    it "stateとnonceは異なる値になる" do
      get line_auth_path
      expect(session[:line_oauth_state]).not_to eq(session[:line_oauth_nonce])
    end

    it "リダイレクトURLに必要なクエリパラメータが含まれる" do
      get line_auth_path
      uri = URI.parse(response.location)
      params = URI.decode_www_form(uri.query).to_h

      expect(params["response_type"]).to eq("code")
      expect(params["client_id"]).to eq("test_channel_id")
      expect(params["scope"]).to eq("profile openid")
      expect(params["state"]).to eq(session[:line_oauth_state])
      expect(params["nonce"]).to eq(session[:line_oauth_nonce])
    end
  end

  describe "GET /users/auth/line/callback" do
    let(:valid_state) { "valid_state_token_123" }
    let(:valid_nonce) { "valid_nonce_token_456" }
    let(:valid_code)  { "valid_authorization_code" }
    let(:line_uid)    { "U1234567890abcdef1234567890abcdef" }
    let(:line_name)   { "LINE太郎" }

    # 認可フローのsessionを事前にセットアップするヘルパー
    def setup_oauth_session(state: valid_state, nonce: valid_nonce)
      # authorize アクションを呼んでsessionを準備
      get line_auth_path
      # 強制的に予測可能な値に書き換え（テスト用）
      session_data = { line_oauth_state: state, line_oauth_nonce: nonce }
      # request.session に直接書き込めないため、Cookieセッションをモック
      allow_any_instance_of(ActionDispatch::Request).to receive(:session)
        .and_wrap_original do |original|
          orig = original.call
          orig.merge!(session_data)
          orig
        end
    end

    # トークン取得APIの成功レスポンスをモック
    def stub_token_success(id_token: "dummy.id.token")
      stub_request(:post, LINE_TOKEN_URL).to_return(
        status: 200,
        body: {
          access_token: "dummy_access_token",
          expires_in: 2592000,
          id_token: id_token,
          refresh_token: "dummy_refresh_token",
          scope: "profile openid",
          token_type: "Bearer"
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    end

    # トークン取得APIの失敗レスポンスをモック
    def stub_token_failure
      stub_request(:post, LINE_TOKEN_URL).to_return(
        status: 400,
        body: { error: "invalid_grant" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    end

    # id_token検証APIの成功レスポンスをモック
    def stub_verify_success(sub: line_uid, name: line_name, nonce: valid_nonce)
      stub_request(:post, LINE_TOKEN_VERIFY_URL).to_return(
        status: 200,
        body: {
          iss: "https://access.line.me",
          sub: sub,
          aud: "test_channel_id",
          exp: (Time.now + 3600).to_i,
          iat: Time.now.to_i,
          nonce: nonce,
          name: name
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    end

    # id_token検証APIの失敗レスポンスをモック
    def stub_verify_failure
      stub_request(:post, LINE_TOKEN_VERIFY_URL).to_return(
        status: 400,
        body: { error_description: "Invalid IdToken." }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    end

    # ============================================================
    # 正常系
    # ============================================================
    context "正常系" do
      before do
        # authorize を呼んでsessionを初期化
        get line_auth_path
      end

      it "新規ユーザーが作成される" do
        # 実際のsessionから state/nonce を取り出す
        state = session[:line_oauth_state]
        nonce = session[:line_oauth_nonce]

        stub_token_success
        stub_verify_success(nonce: nonce)

        expect {
          get line_callback_path, params: { code: valid_code, state: state }
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.provider).to eq("line")
        expect(user.uid).to eq(line_uid)
        expect(user.name).to eq(line_name)
      end

      it "items_path にリダイレクトする" do
        state = session[:line_oauth_state]
        nonce = session[:line_oauth_nonce]

        stub_token_success
        stub_verify_success(nonce: nonce)

        get line_callback_path, params: { code: valid_code, state: state }

        expect(response).to redirect_to(items_path)
        expect(flash[:notice]).to eq("LINEでログインしました")
      end

      it "session内のstate/nonceが削除される" do
        state = session[:line_oauth_state]
        nonce = session[:line_oauth_nonce]

        stub_token_success
        stub_verify_success(nonce: nonce)

        get line_callback_path, params: { code: valid_code, state: state }

        expect(session[:line_oauth_state]).to be_nil
        expect(session[:line_oauth_nonce]).to be_nil
      end

      it "既存LINEユーザーは新規作成されない" do
        state = session[:line_oauth_state]
        nonce = session[:line_oauth_nonce]
        create(:user, :line_user, uid: line_uid, name: "既存ユーザー")

        stub_token_success
        stub_verify_success(nonce: nonce)

        expect {
          get line_callback_path, params: { code: valid_code, state: state }
        }.not_to change(User, :count)
      end
    end

    # ============================================================
    # 異常系
    # ============================================================
    context "ユーザーがLINEでキャンセルした場合" do
      it "ログイン画面にリダイレクトしキャンセルメッセージを表示する" do
        get line_auth_path
        state = session[:line_oauth_state]

        get line_callback_path, params: { error: "access_denied", state: state }

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq("LINEログインをキャンセルしました")
      end

      it "ユーザーが作成されない" do
        get line_auth_path
        state = session[:line_oauth_state]

        expect {
          get line_callback_path, params: { error: "access_denied", state: state }
        }.not_to change(User, :count)
      end
    end

    context "stateが一致しない場合" do
      it "ログイン画面にリダイレクトしエラーメッセージを表示する" do
        get line_auth_path

        get line_callback_path, params: { code: valid_code, state: "wrong_state" }

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq("LINEログインに失敗しました")
      end

      it "ユーザーが作成されない" do
        get line_auth_path

        expect {
          get line_callback_path, params: { code: valid_code, state: "wrong_state" }
        }.not_to change(User, :count)
      end
    end

    context "sessionにstateが無い場合(直接コールバックを叩いた等)" do
      it "ログイン画面にリダイレクトする" do
        # authorize を経由しないので session にstateが入っていない
        get line_callback_path, params: { code: valid_code, state: "any_state" }

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq("LINEログインに失敗しました")
      end
    end

    context "トークン取得APIが失敗した場合" do
      it "ログイン画面にリダイレクトしエラーメッセージを表示する" do
        get line_auth_path
        state = session[:line_oauth_state]

        stub_token_failure

        get line_callback_path, params: { code: valid_code, state: state }

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq("LINEログインに失敗しました")
      end

      it "ユーザーが作成されない" do
        get line_auth_path
        state = session[:line_oauth_state]

        stub_token_failure

        expect {
          get line_callback_path, params: { code: valid_code, state: state }
        }.not_to change(User, :count)
      end
    end

    context "id_token検証APIが失敗した場合" do
      it "ログイン画面にリダイレクトしエラーメッセージを表示する" do
        get line_auth_path
        state = session[:line_oauth_state]

        stub_token_success
        stub_verify_failure

        get line_callback_path, params: { code: valid_code, state: state }

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq("LINEログインに失敗しました")
      end

      it "ユーザーが作成されない" do
        get line_auth_path
        state = session[:line_oauth_state]

        stub_token_success
        stub_verify_failure

        expect {
          get line_callback_path, params: { code: valid_code, state: state }
        }.not_to change(User, :count)
      end
    end

    context "LINEのレスポンスにnameがない場合" do
      it "デフォルト名'LINEユーザー'で作成される" do
        get line_auth_path
        state = session[:line_oauth_state]
        nonce = session[:line_oauth_nonce]

        stub_token_success
        stub_verify_success(nonce: nonce, name: nil)

        get line_callback_path, params: { code: valid_code, state: state }

        expect(User.last.name).to eq("LINEユーザー")
      end
    end
  end
end
