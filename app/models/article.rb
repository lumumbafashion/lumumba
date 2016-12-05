class Article < ApplicationRecord

  extend FriendlyId

  belongs_to :user
  mount_uploader :image, ImageUploader
  acts_as_votable

  validates :title, presence: true, length: { minimum: 20 }
  validates :description, presence: true, length: { minimum: 500 }
  validates :image, presence: true
  validates :user, presence: true
  validates :slug, presence: true

  friendly_id :title, use: :slugged

end
