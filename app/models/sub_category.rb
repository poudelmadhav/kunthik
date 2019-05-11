class SubCategory < ApplicationRecord
  belongs_to :category

  delegate :title, to: :category, prefix: true

  mount_uploader :image, SubCategoryImageUploader
end
