class Address < ApplicationRecord

  belongs_to :user
  has_many :orders

  validates :user, presence: true
  validates :street_address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true
  validates :country, presence: true

  def to_s
    [street_address, city, "#{zip_code} #{state}", country].select(&:present?).join(', ')
  end

end
