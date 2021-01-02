# frozen_string_literal: true

# Google's OAuth2 docs. Make sure you are familiar with all the options
# before attempting to configure this gem.
# https://developers.google.com/accounts/docs/OAuth2Login

Rails.application.config.middleware.use OmniAuth::Builder do

  on_failure { |env| Spree::Admin::OmniauthCallbacksController.action(:oauth_failure).call(env) }

  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], scope: 'email'
end