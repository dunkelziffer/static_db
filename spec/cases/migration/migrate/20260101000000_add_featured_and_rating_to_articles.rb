class AddFeaturedAndRatingToArticles < ActiveRecord::Migration[7.2]
  def change
    add_column :articles, :featured, :boolean, default: false
    add_column :articles, :rating, :integer, default: 3, null: false
  end
end
