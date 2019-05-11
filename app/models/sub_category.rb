class SubCategory < ApplicationRecord
  belongs_to :category
  has_many :items

  delegate :title, to: :category, prefix: true

  mount_uploader :image, SubCategoryImageUploader
end
