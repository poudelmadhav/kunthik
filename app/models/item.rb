class Item < ApplicationRecord
  validates :item_image, presence: true

  belongs_to :user
  belongs_to :sub_category

  mount_uploader :item_image, ItemImageUploader

  delegate :name, to: :sub_category, prefix: true
  delegate :name, to: :user, prefix: true

  def self.search(search)
    if search
      find(:all, :conditions => ['name LIKE ?', "%#{search}%"])
    else
      find(:all)
    end
  end
end
