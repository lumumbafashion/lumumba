class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # validates :color, :quantity, :size, presence: true
  validates :order, presence: true
  validates :product, presence: true

  def remove_from_cart!
    ActiveRecord::Base.transaction do
      order.reload
      order.sub_total -= (self.product.price * self.quantity)
      order.save!
      self.destroy!
    end
  end

end
