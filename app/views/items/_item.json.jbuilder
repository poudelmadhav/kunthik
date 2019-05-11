json.extract! item, :id, :name, :description, :score, :item_image, :sub_category, :user_id, :created_at, :updated_at
json.url item_url(item, format: :json)
