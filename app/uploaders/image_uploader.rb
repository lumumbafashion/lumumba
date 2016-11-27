class ImageUploader < CarrierWave::Uploader::Base

  storage :fog unless Rails.env.in?(%w(test development))

  version :standard do
  end

  version :thumbnail do
  end

  version :product do
  end

end
