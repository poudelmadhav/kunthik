class Category < ApplicationRecord
  validates :title, :image, presence: true

  has_many :sub_categories
  mount_uploader :image, CategoryImageUploader
end
