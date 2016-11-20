require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module LumumbaProd
  class Application < Rails::Application

    config.autoload_paths += Dir[Rails.root.join("app/lib")]

    def self.should_use_cloudinary?
      Rails.env.in?(%w(production staging))
    end

  end
end
