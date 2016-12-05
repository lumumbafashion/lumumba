class AddSlugToArticles < ActiveRecord::Migration[5.0]
  def change
    add_column :articles, :slug, :string, null: false
    add_index :articles, :slug, unique: true
  end
end
