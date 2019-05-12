class CreateComparisons < ActiveRecord::Migration[5.2]
  def change
    create_table :comparisons do |t|
      t.text :reason
      t.integer :item1
      t.integer :item2

      t.timestamps
    end
  end
end
