class OrderItem < ApplicationRecord

  SIZES = %w(S M L)
  QUANTITIES = (1..5).to_a

  belongs_to :order
  belongs_to :product

  validates :order, presence: true
  validates :product, presence: true
  validates :size, presence: true

  def remove_from_cart!
    ActiveRecord::Base.transaction do
      order.reload
      return false unless order.open?
      order.sub_total -= (self.product.price * self.quantity)
      order.save!
      self.destroy!
    end
    true
  end

  def to_s
    "#{product} - Size #{size}. #{"#{quantity} Units" if (quantity || -1) > 1}"
  end

end
