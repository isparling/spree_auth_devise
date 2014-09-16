class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def failure
    flash[:notice] = request.env["omniauth.error"]
    redirect_to '/login'
  end

  # http://sourcey.com/rails-4-omniauth-using-devise-with-twitter-facebook-and-linkedin/
  def stripe_connect
    @user = User.find_for_oauth(env["omniauth.auth"], current_user)
    puts 'OMGHI'

    if @user.persisted?
      puts 'PERSISTED'
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
    else
      puts 'NEW'
      session["devise.#{provider}_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
  
  
  def after_sign_in_path_for(resource)
    if resource.email_verified?
      super resource
    else
      finish_signup_path(resource)
    end
  end
  
end



