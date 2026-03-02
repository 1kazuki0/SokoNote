class ItemStep2Form
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user_id, :integer
  attribute :store, :string
  attribute :brand, :string
  attribute :content_unit, :string
  attribute :pack_unit, :string
  attribute :purchased_on, :date

  validates :store, length: { maximum: 50 }
  validates :brand, length: { maximum: 50 }
  validates :content_unit, length: { maximum: 10 }
  validates :pack_unit, length: { maximum: 10 }
  validates :purchased_on, presence: true

  def store_record
    Store.find_or_initialize_by(user_id: user_id, name: store)
  end
end
