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

    ExceptionEvent = Struct.new(:payload)
    def lograge_formatter(payload, exception: nil, controller: nil)
      loghash = {}

      if exception.present?
        params = controller.try(:params).try(:permit!).try(:to_h) || {}
        loghash['status'] = '500'.red
        loghash.merge! config.lograge.custom_options.call(ExceptionEvent.new(exception: exception, params: params, exception_object: exception))
      end

      loghash['message'] = payload if payload.is_a? String
      loghash.merge! payload       if payload.is_a? Hash

      # Causing error
      if controller.present?
        loghash.merge! config.lograge.custom_payload_method.call(controller)
      end

      return LogStash::Event.new(loghash).to_json if Rails.env.production?

      Lograge::Formatters::KeyValue.new.call loghash
    end

    def backtrace_exception_filter(lines)
      rootpath = Rails.root.to_s
      rootapp  = %r(^(#{rootpath}|/app|/lib|/config))
      paths    = Gem.paths.path.dup

      paths << rootpath

      backtrace = lines.select {|line| rootapp.match(line).present? }

      # if error is not in the application, show all the backtrace of the framework stack
      backtrace = lines if backtrace.count == 0

      # clean up rails root path, and gem paths, less log data
      backtrace = backtrace.map do |line|
        paths.each {|p| line.sub!(p, '') }
        Rails.env.development? ? line.to_s.yellow : line.to_s
      end

      Rails.env.development? ? %(["#{backtrace.try(:join, '", "')}"]) : backtrace
    end

    #
    # Rails.application.log :debug, payload: { hello: 'world' }
    # Rails.application.log :info, message: 'hello'
    # Rails.application.log :error, foo: 'hello', bar: 'world', exception: ex
    #
    def log( level, exception: nil, controller: nil, **payload)
      # on production @timestamp is automatically added
      record = Rails.env.production? ? payload : { at: Time.now }.merge(payload)
      line   = Rails.application.lograge_formatter(record, exception: exception, controller: controller)
      Rails.logger.send level, line

    rescue => ex
      log_failure = { class: ex.class.to_s, message: ex.to_s }
      exception_message = exception.present? ? { class: exception.class.to_s, message: exception.to_s } : {}

      line = Rails.application.lograge_formatter(record.merge({ exception_message: exception_message, log_failure: log_failure }))

      Rails.logger.send level, line
    end
  end
end
