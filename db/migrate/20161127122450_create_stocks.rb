class CreateStocks < ActiveRecord::Migration[5.0]
  def up

    create_table :stocks do |t|
      t.references :product, foreign_key: true, null: false
      t.timestamps
    end

    add_column :products, :initial_stock, :integer, null: false

  end
end
