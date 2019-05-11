class SubCategory < ApplicationRecord
  belongs_to :category

  delegate :title, to: :category, prefix: true
end
