class Item < ApplicationRecord
  validates :item_image, presence: true

  belongs_to :user
  belongs_to :sub_category

  mount_uploader :item_image, ItemImageUploader

  delegate :name, to: :sub_category, prefix: true
  delegate :name, to: :user, prefix: true
end
