# 新しいフォームオブジェクトのクラス items/new_step1ファイル
class PurchaseStep1Form
  # モデルのような機能(:Model)とカラムのような機能(:Attributes)を追加
  # モデルと同じように扱える、属性（カラム）を定義できる
  include ActiveModel::Model
  include ActiveModel::Attributes
  # 現在のユーザーIDを参照するために、user_idを使用するために記載（current_userはcontrollerとviewでしか使用できない)
  # attr_accessor :user_id

  # --- 1.フォームで扱う項目（属性）を定義する ---
  # item_name,category_nameは文字列型
  # 他4つは整数型
  attribute :user_id, :integer
  attribute :item_name, :string
  attribute :category_name, :string
  attribute :content_quantity, :integer
  attribute :pack_quantity, :integer
  attribute :price, :integer
  attribute :tax_rate, :integer

  # --- 2.バリデーションチェック ---
  # 必須項目：item_name, category_name, content_quantity, pack_quantity, price,tax_rate
  # 30文字以内：item_name, category_name
  # 0より大きい：content_quantity, pack_quantity, price
  # 整数のみ：pack_quantity, price
  # 0か8か10のみ：tax_rate
  validates :item_name, presence: true, length: { maximum: 30 }
  validates :category_name, presence: true, length: { maximum: 30 }
  validates :content_quantity, presence: true, numericality: { greater_than: 0 }
  validates :pack_quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :tax_rate, presence: true, inclusion: { in: [ 0, 8, 10 ] }
  # private内で定義しているcategory_recordとitem_recordのバリデーションを実行
  # validate :category_record
  # validate :item_record

  # # このクラス内部だけ使用するので明示
  # private

  # 現在のユーザーとcategory_nameが同じデータベースにあるか確認し、なければ作成。(のちに@category_record ||= を前においてリファクタリング)
  def category_record
    Category.find_or_initialize_by(user_id: user_id, name: category_name)
  end

  # 現在のユーザーとcategory_record（category_name)と、item_nameが同じデータベースにあるか確認し、なければ作成（のちに@item_record ||= を前においてリファクタリング）
  def item_record
    Item.find_or_initialize_by(
    user_id: user_id,
    category: category_record,
    name: item_name
    )
  end
end
