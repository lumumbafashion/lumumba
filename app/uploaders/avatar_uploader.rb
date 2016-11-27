class AvatarUploader < CarrierWave::Uploader::Base

  storage :fog unless Rails.env.in?(%w(test development))
  process convert: 'png'
  process tags: ['post_picture']

  version :standard do
    process resize_to_fill: [100, 150, :north]
  end

  version :thumbnail do
    # eager
    # resize_to_fit(50, 50)
  end

  version :product do
    process resize_to_fill: [260, 260, :north]
  end

end
