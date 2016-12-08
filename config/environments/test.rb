Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.public_file_server.enabled = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :stderr
  config.action_mailer.default_url_options = { host: Lumumba::Application.host }
end
