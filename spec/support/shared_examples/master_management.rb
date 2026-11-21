# 設定画面から開くマスタ管理画面（カテゴリー・店舗・単位（内容量））の共通System spec
# 3画面は文言・パス・文字数上限以外の構成が同じため、shared_examplesで共通化する
#
# 呼び出し側で以下を指定する
#   factory:     FactoryBotのファクトリ名（フォームのパラメータ名にも使う。例: :category → category[name]）
#   label:       画面の見出し・フラッシュに使われる名前（例: "カテゴリー"）
#   field_label: 名前欄の項目名（エラーメッセージに使われる。例: "カテゴリー名"）
#   max_length:  名前の最大文字数
#   index_path / new_path / edit_path: 各画面のパスヘルパー名
#   sample_name: 登録・編集で入力する名前
RSpec.shared_examples "マスタ管理画面" do |factory:, label:, field_label:, max_length:, index_path:, new_path:, edit_path:, sample_name:|
  let(:user) { create(:user) }

  # JSドライバが必要なテスト（js: true）以外はrack_testで実行する
  before do |example|
    driven_by(:rack_test) unless example.metadata[:js]
    sign_in user
  end

  # マスタのカードを名前で特定する
  def master_card(name)
    find(".swipe-card", text: name)
  end

  def fill_in_name(value, factory)
    fill_in "#{factory}[name]", with: value
  end

  describe "一覧表示" do
    context "1件以上登録されている場合" do
      let!(:record_a) { create(factory, user: user) }
      let!(:record_b) { create(factory, user: user) }
      let!(:other_users_record) { create(factory) }

      before { visit send(index_path) }

      it "見出しが表示される" do
        expect(page).to have_content("#{label}一覧")
      end

      it "自分が登録したものだけが表示される" do
        expect(page).to have_css(".swipe-card", count: 2)
        expect(page).to have_css(".swipe-card", text: record_a.name)
        expect(page).to have_css(".swipe-card", text: record_b.name)
        expect(page).not_to have_css(".swipe-card", text: other_users_record.name)
      end

      it "追加ボタンから登録画面に遷移できる" do
        click_link "#{label}追加"
        expect(page).to have_current_path(send(new_path))
      end
    end

    context "0件の場合" do
      before { visit send(index_path) }

      it "0件時のメッセージが表示される" do
        expect(page).to have_content("#{label}がありません")
        expect(page).not_to have_css(".swipe-card")
      end

      it "登録ボタンから登録画面に遷移できる" do
        click_link "#{label}を登録する"
        expect(page).to have_current_path(send(new_path))
      end
    end
  end

  describe "登録" do
    before { visit send(new_path) }

    it "見出しが表示される" do
      expect(page).to have_content("#{label}登録")
    end

    context "入力値が正常な場合" do
      it "登録に成功し、一覧画面に表示される" do
        fill_in_name(sample_name, factory)
        expect { click_button "この内容で登録する" }.to change { user.public_send(factory.to_s.pluralize).count }.by(1)
        expect(page).to have_current_path(send(index_path))
        expect(page).to have_content("#{label}を登録しました")
        expect(page).to have_css(".swipe-card", text: sample_name)
      end
    end

    context "名前が未入力の場合" do
      it "登録に失敗し、エラーメッセージが表示される" do
        fill_in_name("", factory)
        expect { click_button "この内容で登録する" }.not_to change { user.public_send(factory.to_s.pluralize).count }
        expect(page).to have_content("#{label}登録に失敗しました")
        expect(page).to have_content("#{field_label}を入力してください")
      end
    end

    context "名前が#{max_length + 1}文字以上の場合" do
      it "登録に失敗し、エラーメッセージが表示される" do
        fill_in_name("あ" * (max_length + 1), factory)
        expect { click_button "この内容で登録する" }.not_to change { user.public_send(factory.to_s.pluralize).count }
        expect(page).to have_content("#{field_label}は#{max_length}文字以内で入力してください")
      end
    end

    context "名前が#{max_length}文字の場合" do
      it "登録に成功する" do
        fill_in_name("あ" * max_length, factory)
        expect { click_button "この内容で登録する" }.to change { user.public_send(factory.to_s.pluralize).count }.by(1)
        expect(page).to have_content("#{label}を登録しました")
      end
    end

    context "登録済みの名前と重複する場合" do
      before { create(factory, user: user, name: sample_name) }

      it "登録に失敗し、エラーメッセージが表示される" do
        fill_in_name(sample_name, factory)
        expect { click_button "この内容で登録する" }.not_to change { user.public_send(factory.to_s.pluralize).count }
        expect(page).to have_content("#{field_label}はすでに存在します")
      end
    end

    context "他のユーザーが登録済みの名前と重複する場合" do
      before { create(factory, name: sample_name) }

      it "登録に成功する" do
        fill_in_name(sample_name, factory)
        expect { click_button "この内容で登録する" }.to change { user.public_send(factory.to_s.pluralize).count }.by(1)
        expect(page).to have_content("#{label}を登録しました")
      end
    end
  end

  describe "編集" do
    let!(:record) { create(factory, user: user) }

    before do
      visit send(index_path)
      within(master_card(record.name)) { click_link "編集" }
    end

    it "一覧の編集ボタンから編集画面に遷移し、登録済みの名前が入力されている" do
      expect(page).to have_current_path(send(edit_path, record))
      expect(page).to have_content("#{label}編集")
      expect(page).to have_field("#{factory}[name]", with: record.name)
    end

    context "入力値が正常な場合" do
      it "更新に成功し、一覧画面に変更後の名前が表示される" do
        fill_in_name(sample_name, factory)
        click_button "この内容で更新する"
        expect(page).to have_current_path(send(index_path))
        expect(page).to have_content("#{label}を更新しました")
        expect(page).to have_css(".swipe-card", text: sample_name)
        expect(record.reload.name).to eq(sample_name)
      end
    end

    context "名前が未入力の場合" do
      it "更新に失敗し、エラーメッセージが表示される" do
        original_name = record.name
        fill_in_name("", factory)
        click_button "この内容で更新する"
        expect(page).to have_content("#{label}更新に失敗しました")
        expect(page).to have_content("#{field_label}を入力してください")
        expect(record.reload.name).to eq(original_name)
      end
    end

    context "名前が#{max_length + 1}文字以上の場合" do
      it "更新に失敗し、エラーメッセージが表示される" do
        original_name = record.name
        fill_in_name("あ" * (max_length + 1), factory)
        click_button "この内容で更新する"
        expect(page).to have_content("#{field_label}は#{max_length}文字以内で入力してください")
        expect(record.reload.name).to eq(original_name)
      end
    end

    context "登録済みの別の名前と重複する場合" do
      before { create(factory, user: user, name: sample_name) }

      it "更新に失敗し、エラーメッセージが表示される" do
        original_name = record.name
        fill_in_name(sample_name, factory)
        click_button "この内容で更新する"
        expect(page).to have_content("#{field_label}はすでに存在します")
        expect(record.reload.name).to eq(original_name)
      end
    end
  end

  describe "削除", js: true do
    let!(:record) { create(factory, user: user) }

    before { visit send(index_path) }

    # スワイプ操作は spec/support/swipe_helpers.rb で定義
    it "確認ダイアログで「削除する」を選ぶと削除される" do
      swipe_and_click_delete(master_card(record.name))
      within("#turbo-confirm") do
        expect(page).to have_content("本当に削除しますか？")
        click_button "削除する"
      end
      expect(page).to have_content("#{label}を削除しました")
      expect(page).not_to have_css(".swipe-card", text: record.name)
      expect(record.class.exists?(record.id)).to be false
    end

    it "確認ダイアログで「キャンセル」を選ぶと削除されない" do
      swipe_and_click_delete(master_card(record.name))
      within("#turbo-confirm") { click_button "キャンセル" }
      expect(page).to have_css(".swipe-card", text: record.name)
      expect(record.class.exists?(record.id)).to be true
    end
  end
end
