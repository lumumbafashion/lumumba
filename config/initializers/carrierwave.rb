require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

if Rails.env.in?(%w(test development))

  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end

  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      storage :file

      def cache_dir
        "#{Rails.root}/public/uploads/#{Rails.env}/tmp"
      end

      def store_dir
        "#{Rails.root}/public/uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    end
  end

else

  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
        provider: "AWS",
        use_iam_profile: true, # for this to work, one must assign AmazonS3FullAccess to aws-elasticbeanstalk-ec2-role in https://console.aws.amazon.com/iam/home?region=eu-west-1#/roles/aws-elasticbeanstalk-ec2-role
        region: 'eu-west-1',
    }
    config.fog_directory = "lumumba-fog-#{Rails.env}"
    config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" }
    Excon.defaults[:write_timeout] = 500
  end

end
