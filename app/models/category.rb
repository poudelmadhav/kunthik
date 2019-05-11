class Category < ApplicationRecord
  validates :name, presence: true

  has_many :sub_categories
  mount_uploader :image, CategoryImageUploader
end
