class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :ensure_production_hostname

  def authenticate_admin!
    authenticate_user!
    unless current_user.nil?
      unless current_user.is_admin?
        flash[:error] = 'Access denied'
        redirect_to root_path
      end
    end
  end

  def not_found
    render file: Rails.root.join('public', '404.html'), layout: false, status: 404
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

  private
  def after_sign_in_path_for(resource)
    session["user_return_to"] || user_path(resource.slug)
  end

end
