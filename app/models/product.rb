class Product < ApplicationRecord

  mount_uploader :main_image, ImageUploader
  mount_uploader :first_thumbnail, ImageUploader
  mount_uploader :second_thumbnail, ImageUploader
  mount_uploader :third_thumbnail, ImageUploader

  has_many :order_items
  has_many :stocks
  validates :main_image, :first_thumbnail, :second_thumbnail, :description, :designer, :price, :name, :slug, presence: true
  validates :initial_stock, presence: true, numericality: {greater_than_or_equal_to: 1}
  validate :initial_stock_cannot_change, on: :update

  # don't use after_commit - we want to leverage transactions.
  after_create :create_stock_records
  before_destroy :destroy_stock_records

  extend FriendlyId
  friendly_id :name, use: :slugged

  def to_s
    name
  end

  def in_stock? quantity
    stocks.count >= quantity
  end

  def out_of_stock? quantity
    stocks.count < quantity
  end

  def initial_stock_cannot_change
    if changes[:initial_stock]
      errors[:initial_stock] << 'No puede modificarse el stock inicial de un producto.'
    end
  end

  def create_stock_records
    initial_stock.times do
      Stock.create!(product: self)
    end
  end

  def destroy_stock_records
    stocks.destroy_all
  end

end
