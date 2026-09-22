# SokoNote

家計簿・底値管理アプリ（個人開発）。ユーザーが購入した商品の価格を記録し、底値（過去最安値）を把握できるようにする。デプロイ先: Render（`https://www.sokonote.com/`）。

## 技術スタック

- Rails 8.0.5 / Ruby（`.ruby-version`参照）
- PostgreSQL
- Devise（+ devise-i18n）による認証
- Hotwire（Turbo + Stimulus）、Tailwind CSS v4、esbuild
- RSpec（+ FactoryBot, Faker）

## よく使うコマンド

- サーバー起動: `bin/dev`
- Lint: `bundle exec rubocop --parallel`
- セキュリティスキャン: `bundle exec brakeman --no-pager`
- テスト: `bundle exec rspec spec/models spec/requests spec/system`
- DBセットアップ: `bundle exec rails db:create db:schema:load`

これらはCI（`.github/workflows/ci.yml`）で実行されているものと同じコマンド。変更をコミットする前に手元で実行し、CIと同じ基準を満たしていることを確認する。

## 絶対に読み書きしないファイル

`config/master.key`, `.env` / `.env.*`, `config/credentials.yml.enc`, `config/database.yml` には認証情報が含まれる。これらは読み書きしない（`.claude/settings.json`側でも拒否設定済み）。

## 開発ワークフロー

- 作業前に必ず`main`から新しいブランチを作成する。ブランチ名は `<type>/<kebab-case-の英語説明>`（type: `feature` / `fix` / `chore` / `docs` / `test`）。例: `feature/add-search-filter`, `fix/login-redirect-bug`
- コミットメッセージは `<type>: 日本語での説明`（例: `feature: 検索フィルタ機能を実装`, `fix: ログイン後のリダイレクト先を修正`）
- Issueを作成する場合は `.github/ISSUE_TEMPLATE/issueテンプレート.md` のフォーマット（As Is / To Be / やることリスト / 補足）に従い、`gh issue create --assignee 1kazuki0` で作成する
- PRを作成する場合は `gh pr create` を使い、本文は `.github/PULL_REQUEST_TEMPLATE.md`（関連ISSUE / 変更内容 / 動作確認 / 補足・レビュアーへのメモ）に従う

## Bashコマンド実行前の確認

Bashツールで何らかのコマンドを実行する前に、そのコマンドが何をしようとしているのかを日本語で簡潔に説明すること。説明した後は、チャット上で「実行してよいですか？」のように明示的な返答（「はい」等の入力）を求めず、そのままツールを呼び出す（実際の実行許可はツールの許可ダイアログに委ねる）。
