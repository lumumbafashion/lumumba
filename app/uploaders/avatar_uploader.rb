class AvatarUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  if Lumumba::Application.should_use_cloudinary?
    include Cloudinary::CarrierWave
    process convert: 'png'
    process tags: ['post_picture']
  end

  version :standard do
    if Lumumba::Application.should_use_cloudinary?
      process resize_to_fill: [100, 150, :north]
    end
  end

  version :thumbnail do
    if Lumumba::Application.should_use_cloudinary?
      eager
      resize_to_fit(50, 50)
    end
  end

  version :product do
    if Lumumba::Application.should_use_cloudinary?
      process resize_to_fill: [260, 260, :north]
    end
  end
end
