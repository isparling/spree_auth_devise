class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def failure
    flash[:notice] = "Kindly sign in with your Stripe account in order to continue"
    redirect_to '/login'
  end
  
  def stripe_connect
    # Delete the code inside of this method and write your own.
    # The code below is to show you where to access the data.

    raise request.env["omniauth.auth"].to_yaml
    
  end

end