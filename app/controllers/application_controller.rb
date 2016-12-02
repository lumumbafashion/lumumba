class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_csrf_errors

  before_action :ensure_production_hostname
  before_action :prepare_order_item_count_value

  def authenticate_admin!
    authenticate_user!
    unless current_user.nil?
      unless current_user.is_admin?
        flash[:error] = 'Access denied'
        redirect_to root_path
      end
    end
  end

  def ensure_production_hostname
    if Rails.env.in?(%w(production staging))
      hostname = Lumumba::Application.host
      protocol = Lumumba::Application.protocol
      if request.host != hostname
        redirect_to "#{protocol}://#{hostname}#{request.fullpath}"
      end
    end
  end

  def handle_not_found
    SafeLogger.error(rollbar: false) { "404 - not found: #{logging_info_for_error_handling}" }
    render file: Rails.root.join('public', '404.html'), layout: false, status: 404
  end

  def handle_csrf_errors
    SafeLogger.warn { "ActionController::InvalidAuthenticityToken for #{logging_info_for_error_handling}" }
    flash[:warning] = 'Sorry, there was a problem authenticating your request (CSRF token). Please try again.'
    redirect_back(fallback_location: root_path)
  end

  def expire_user_order_item_count_cache!
    Rails.cache.delete order_item_count_cache_key_for current_user
  end

  def prepare_order_item_count_value
    cache_key = order_item_count_cache_key_for current_user
    @order_item_count_value = if current_user
      Rails.cache.fetch(cache_key, {expires_in: 8.minutes}){
        current_user.orders.open.map do |order|
          order.order_items.map(&:quantity).sum
        end.sum
      }
    else
      0
    end
  end

  private

  def after_sign_in_path_for(resource)
    session["user_return_to"] || user_path(resource.slug)
  end

  def logging_info_for_error_handling
    "#{request.try(:fullpath)} - current_user.id: #{current_user.try(:id) || 'nil'}"
  end

  def order_item_count_cache_key_for user
    "prepare_order_item_count_value_#{user.try(:id)}"
  end

end
