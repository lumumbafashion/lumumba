class AvatarUploader < CarrierWave::Uploader::Base

  storage :fog unless Rails.env.in?(%w(test development))

  def store_dir
    "#{super}/uploads/avatar_uploader/#{model.class.to_s.underscore}/#{model.id}"
  end

  version :standard do
  end

  version :thumbnail do
  end

  version :product do
  end

end
