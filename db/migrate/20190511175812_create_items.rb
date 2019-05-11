class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.integer :score
      t.string :item_image
      t.references :sub_category, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
