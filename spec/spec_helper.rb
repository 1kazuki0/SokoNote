# RSpec（テスト）全体の共通設定を書くファイル

# このファイルはrails generate rspec:installコマンドによって生成。
# 慣習として、specフォルダに配置され、RSpecはそのフォルダを$LOAD_PATHに追加する←$LOAD_PATHとはRubyがファイルを探す場所のリスト。
# つまりわざわざ require './spec/my_helper.rb' とフルパスを書かなくても、require 'my_helper' だけで済む

# 自動生成された.rspecファイルに--require spec_helperという設定が書かれている。
# これによりこのファイルは常に自動で読み込まれるので、各specファイルに明示的にrequireする必要がない。

# このファイルは 常に読み込まれるので、できるだけ軽く保つことが推奨されている。
# このファイルで 重いライブラリを require するとすべてのテスト実行の起動時間が長くなる。
# たとえ、そのライブラリを必要としないテストファイルを1つだけ実行した場合でも、毎回読み込まれてしまう。

# その代わりに、追加の依存関係や設定を書いた別のヘルパーファイルを作って、それが必要なspecファイルからだけ読み込むようにしましょう。
# 　→　つまり、重いものはrails_helper.rbに書く。
# 参照 https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

# Rspec全体の設定。設定内容はconfigという名前で扱う
RSpec.configure do |config|
  # 以下は通常trueで、Rspecの期待値検証をどのライブラリで動かすか決めている。ここでは:rspec  でRspecを使用している。
  config.expect_with :rspec do |expectations|
    # 以下はカスタムマッチャー（自分で作った検証ルール）を連結したとき、失敗メッセージを詳しくする設定
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  # 以下はRspecのmock（テスト用の偽物データ）機能の設定を書く
  config.mock_with :rspec do |mocks|
    # 以下は存在しないメソッドをモック（偽物化）するのを禁止する安全機能。存在しないメソッドをモックしようとしたらエラーにする
    mocks.verify_partial_doubles = true
  end

  # 以下はデフォルトでオフにする方法はなく、shared_context（共通のテスト設定）をどこに適用するかというルール
  # apply_to_host_groupsこれは、describe contextという箱
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # 以降は自由にカスタマイズできる
  # 有効にしたい場合はコメントアウトを外す

  # 以下は、:focusが付いたテストだけ実行する。
  # focusタグが何もついていない場合は全ての例が実行される。
  # config.filter_run_when_matching :focus

  # 前回失敗したテストだけをspec/examples.txtに保存する
  # 保存することで、次回のテストで失敗したテストだけ実行するコマンドをうつと時間短縮になる。
  # config.example_status_persistence_file_path = "spec/examples.txt"


  # Rubyがもともと持っているクラス（StringやArrayなど）を、RSpecが勝手に改造するのを禁止する
  # 参照 https://rspec.info/features/3-12/rspec-core/configuration/zero-monkey-patching-mode/
  # config.disable_monkey_patching!

  # 個々のファイルを実行する時は詳細な出力を許可すると便利。以下
  # if config.files_to_run.one?
    # 詳細な出力にはdocumentation formatterを使用。ただし、フォーマッタが既に設定されていない場合は除きます。
    # config.default_formatter = "doc"
  # end

  # 以下は最も遅い10個のrspecを出力する
  # config.profile_examples = 10

  # 順序依存性？を明らかにするためにランダムな順番で実行する。
  # デバッグをしたい場合は、シード値を指定して順序を修正する（シード値は実行後に表示される）
  # config.order = :random

  # `--seed` CLIオプションを使用してグローバルランダムシートのシード値を指定する
  # これにより`--seed` を使用して、ランダム化に関連するテストの失敗を、失敗の原因となった値と同じ `--seed` 値を渡すことで、確定的に再現できます。
  # Kernel.srand config.seed

  # gem capybaraを使用する(visit, click_on, fill_inなどの操作をブラウザで操作してくれる）
  require "capybara/rspec"

end
