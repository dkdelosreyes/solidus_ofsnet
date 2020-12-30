module Spree
  module UserRegistrationsControllerDecorator

    def self.prepended(base)
      base.prepend_before_action :check_captcha, only: [:create]
    end

    private

    def check_captcha
      success          = verify_recaptcha(action: 'signup', minimum_score: 0.4)
      checkbox_success = verify_recaptcha(secret_key: ENV['RECAPTCHA_SECRET_KEY_V2']) unless success

      unless success || checkbox_success
        @show_checkbox_recaptcha = true
        self.resource = resource_class.new sign_up_params
        resource.validate # Look for any other validation errors besides reCAPTCHA
        set_minimum_password_length
        respond_with_navigational(resource) { render :new }
      end
    end

    Spree::UserRegistrationsController.prepend self
  end
end