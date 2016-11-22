require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module Lumumba
  class Application < Rails::Application

    config.autoload_paths += Dir[Rails.root.join("app/lib")]

    def self.host env=nil
      case (env.presence || Rails.env)
      when 'production'
        'www.lumumba.com'
      when'staging'
        'lumumba-staging.eu-west-1.elasticbeanstalk.com'
      when 'test', 'development'
        'localhost'
      end
    end

    def self.should_use_cloudinary?
      Rails.env.in?(%w(production staging))
    end

  end
end
