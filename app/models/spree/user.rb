module Spree
  class User < ActiveRecord::Base
    include Core::UserAddress
    include Core::UserPaymentSource

    devise :database_authenticatable, :omniauthable, :registerable, :recoverable,
           :rememberable, :trackable, :validatable, :encryptable, :encryptor => 'authlogic_sha512'

    has_many :orders

    before_validation :set_login
    before_destroy :check_completed_orders

    users_table_name = User.table_name
    roles_table_name = Role.table_name

    scope :admin, -> { includes(:spree_roles).where("#{roles_table_name}.name" => "admin") }

    class DestroyWithOrdersError < StandardError; end

    def self.admin_created?
      User.admin.count > 0
    end

    def admin?
      has_spree_role?('admin')
    end
    
    # http://sourcey.com/rails-4-omniauth-using-devise-with-twitter-facebook-and-linkedin/
    def self.find_for_oauth(auth, signed_in_resource = nil)
      
      binding.remote_pry
      puts 'hi'
      
      # Get the identity and user if they exist
      identity = Identity.find_for_oauth(auth)

      # If a signed_in_resource is provided it always overrides the existing user
      # to prevent the identity being locked with accidentally created accounts.
      # Note that this may leave zombie accounts (with no associated identity) which
      # can be cleaned up at a later date.
      user = signed_in_resource ? signed_in_resource : identity.user

      # Create the user if needed
      if user.nil?

        # Get the existing user by email if the provider gives us a verified email.
        # If no verified email was provided we assign a temporary email and ask the
        # user to verify it on the next step via UsersController.finish_signup
        email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
        email = auth.info.email if email_is_verified
        user = User.where(:email => email).first if email

        # Create the user if it's a new registration
        if user.nil?
          user = User.new(
            name: auth.extra.raw_info.name,
            #username: auth.info.nickname || auth.uid,
            email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
            password: Devise.friendly_token[0,20]
          )
          user.skip_confirmation!
          user.save!
        end
      end

      # Associate the identity with the user if needed
      if identity.user != user
        identity.user = user
        identity.save!
      end
      user
    end
  

    protected
      def password_required?
        !persisted? || password.present? || password_confirmation.present?
      end
      
      def email_verified?
        self.email && self.email !~ TEMP_EMAIL_REGEX
      end

    private

      def check_completed_orders
        raise DestroyWithOrdersError if orders.complete.present?
      end

      def set_login
        # for now force login to be same as email, eventually we will make this configurable, etc.
        self.login ||= self.email if self.email
      end
  end
end
