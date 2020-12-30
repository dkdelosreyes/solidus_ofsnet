module Spree::Admin
  module UserSessionsControllerDecorator

    def self.prepended(base)
      base.prepend_before_action :check_captcha, only: [:create]
    end

    private

    def check_captcha
      success          = verify_recaptcha(action: 'admin_login', minimum_score: 0.4)
      checkbox_success = verify_recaptcha(secret_key: ENV['RECAPTCHA_SECRET_KEY_V2']) unless success

      unless success || checkbox_success
        @show_checkbox_recaptcha = true
        self.resource = resource_class.new sign_in_params
        respond_with_navigational(resource) { render :new }
      end
    end

    Spree::Admin::UserSessionsController.prepend self
  end
end