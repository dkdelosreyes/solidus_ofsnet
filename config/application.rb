require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SolidusOfsnet
  class Application < Rails::Application
    # Load application's model / class decorators
    initializer 'spree.decorators' do |app|
      config.to_prepare do
        Dir.glob(Rails.root.join('app/**/*_decorator*.rb')) do |path|
          require_dependency(path)
        end
      end
    end

    # Load application's view overrides
    initializer 'spree.overrides' do |app|
      config.to_prepare do
        Dir.glob(Rails.root.join('app/overrides/*.rb')) do |path|
          require_dependency(path)
        end
      end
    end

    initializer "spree.gateway.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::TelrGateway
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.i18n.fallbacks = [:en]

    config.action_mailer.asset_host = ENV['MAILER_ASSET_HOST']

    config.time_zone = 'Asia/Dubai'

    # For custom error pages
    config.exceptions_app = self.routes

    # Causing error when creating DB in AWS - No such middleware to insert after: ActionDispatch::Static
    # HTML compression
    # config.middleware.insert_after ActionDispatch::Static, Rack::Deflater
  end
end
