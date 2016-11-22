require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module Lumumba
  class Application < Rails::Application

    config.autoload_paths += Dir[Rails.root.join("app/lib")]

    def self.host env=nil
      case (env.presence || Rails.env)
      when 'production'
        ENV['RAILS_APPLICATION_HOST'].presence || 'www.lumumba.com'
      when'staging'
        'lumumba-staging.eu-west-1.elasticbeanstalk.com'
      when 'test', 'development'
        'localhost'
      end
    end

    def self.protocol env=nil
      case (env.presence || Rails.env)
      when 'production'
        if ENV['RAILS_APPLICATION_HOST'].present?
          'http'
        else
          'https'
        end
      when 'staging' 'test', 'development'
        'http'
      end
    end

    def self.should_use_cloudinary?
      Rails.env.in?(%w(production staging))
    end

    config.action_mailer.default_url_options ||= {}
    config.action_mailer.default_url_options[:host] = self.host
    config.asset_host = "#{self.protocol}://#{self.host}"
    Rails.application.routes.default_url_options[:host] = self.host
    Rails.application.routes.default_url_options[:protocol] = self.protocol
    self.host # explicitly call `host`, to ensure (in production) that it doesn't raise anything.

    Rollbar.configuration.environment = host

  end
end
