class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def stripe_connect
    # Delete the code inside of this method and write your own.
    # The code below is to show you where to access the data.
    
    binding.pry
    puts 'hi'
    raise request.env["omniauth.auth"].to_yaml
  end

end