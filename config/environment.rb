# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

if %w(staging production).include?(ENV['RAILS_ENV'] || ENV['RACK_ENV'])
  ActionMailer::Base.smtp_settings = {
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    domain: 'heroku.com',
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }
end
