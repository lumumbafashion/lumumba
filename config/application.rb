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

    def self.port
      if Rails.env.development?
        3000
      elsif Rails.env.test?
        @@application_port ||= "5#{1000 + (Random.rand * 8999).to_i}".to_i
      else
        nil
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
      when 'staging', 'test', 'development'
        'http'
      end
    end

    config.action_mailer.default_url_options ||= {}
    config.action_mailer.default_url_options[:host] = self.host
    config.action_mailer.default_url_options[:port] = self.port if self.port
    config.asset_host = "#{self.protocol}://#{self.host}#{":" + self.port.to_s if self.port}"
    Rails.application.routes.default_url_options[:host] = self.host
    Rails.application.routes.default_url_options[:port] = self.port if self.port
    Rails.application.routes.default_url_options[:protocol] = self.protocol
    self.host # explicitly call `host`, to ensure (in production) that it doesn't raise anything.

    Rollbar.configuration.environment = host

  end
end
