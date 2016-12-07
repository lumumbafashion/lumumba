class User < ApplicationRecord

  has_many :designs
  has_many :articles
  has_many :addresses
  has_many :orders
  has_many :votes, class_name: ActsAsVotable::Vote, as: :voter

  extend FriendlyId
  friendly_id :first_name, use: [:slugged, :finders, :history]

  acts_as_voter
  mount_uploader :avatar, ImageUploader

  devise :database_authenticatable, :registerable, :omniauthable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  MALE = 'Male'
  FEMALE = 'Female'
  OTHER_GENDER = 'Gender Free'
  GENDERS = [MALE, FEMALE, OTHER_GENDER]

  validates :gender, inclusion: GENDERS, allow_blank: true

  def self.from_omniauth(auth)
    _email = auth.info.email.presence
    _image = auth.info.image.presence
    instance = find_by(email: _email) || where(provider: auth.provider, uid: auth.uid).first_or_initialize
    instance.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      if _email
        user.email = _email
        user.confirmed_at ||= Time.current
      end
      if _image
        user.image = "#{_image}#{'?type=large' if auth.provider.to_s == 'facebook'}"
      end
      [
        [:gender, auth.extra.raw_info.try(:gender).try(:capitalize)],
        [:first_name, auth.info.first_name],
        [:last_name, auth.info.last_name],
        [:location, auth.info.location],
        [:about, auth.info.about]
      ].each do |attr, value|
        if value.present?
          user.send("#{attr}=", value)
        end
      end
      user.save!
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info']
        user.email = data['email'] if user.email.blank?
      end
    end
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def is_admin?
    admin == true
  end

  def after_confirmation
    WelcomeMailer.signup_confirmation(self).deliver
  end

  def to_s
    "#{first_name} #{last_name}"
  end

end
