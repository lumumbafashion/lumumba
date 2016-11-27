class CkeditorAttachmentFileUploader < CarrierWave::Uploader::Base

  include Ckeditor::Backend::CarrierWave

  storage :fog unless Rails.env.in?(%w(test development))

  def store_dir
    "#{super}/uploads/ckeditor/attachments/#{model.id}"
  end

  def extension_white_list
    Ckeditor.attachment_file_types
  end

end
