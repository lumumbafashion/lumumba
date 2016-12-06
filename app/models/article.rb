class Article < ApplicationRecord

  extend FriendlyId
  acts_as_votable
  mount_uploader :image, ImageUploader

  belongs_to :user
  has_many :votes, class_name: ActsAsVotable::Vote, as: :votable

  validates :title, presence: true, length: { minimum: 20 }
  validates :description, presence: true, length: { minimum: 500 }
  validates :image, presence: true
  validates :user, presence: true
  validates :slug, presence: true

  friendly_id :title, use: :slugged

end
