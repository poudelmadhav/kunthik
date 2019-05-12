class AddDefaultValueScoreToItems < ActiveRecord::Migration[5.2]
  def change
    change_column :items, :score, :integer, :default => 0
  end
end
