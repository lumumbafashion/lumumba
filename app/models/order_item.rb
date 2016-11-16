class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :color, :quantity, :size, presence: true
  validates :order, presence: true
  validates :product, presence: true

  def get_product
    Product.find(product_id)
  end

  def remove_from_cart!
    ActiveRecord::Base.transaction do
      order.reload
      order.sub_total -= (self.get_product.price * self.quantity)
      order.save!
      self.destroy!
    end
  end

end
