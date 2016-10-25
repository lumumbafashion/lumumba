class Address < ApplicationRecord
  belongs_to :user

  validates :street_address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true
  validates :country, presence: true
end
