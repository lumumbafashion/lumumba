class AddAboutFieldsToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :about_designer, :text, null: false
    add_column :products, :about_lumumba, :text, null: false
  end
end
