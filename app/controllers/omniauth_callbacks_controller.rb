class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    user = User.find_or_initialize_from_omniauth(request.env['omniauth.auth'])
    user.save
    if user.id
      if user.confirmed?
        flash[:success] = 'Welcome!'
      end
      sign_in user
      redirect_to session["user_return_to"] || user_path(user.slug)
    else
      if (user.errors[:email] || []).include?("can't be blank")
        flash[:error] = 'Sorry, login/signup with Facebook failed. Did you allow the facebook email to appear? You might have blocked it in the Facebook permissions screen.'
      else
        flash[:error] = 'Sorry, there has been an error when logging in / signing up with Facebook. Please try again, or use email/password instead. Or contact us!'
      end
      session['devise.facebook_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
  def failure
    redirect_to root_path
  end
  alias facebook all
end
