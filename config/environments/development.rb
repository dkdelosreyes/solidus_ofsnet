default_url_options = Rails.application.routes.default_url_options

app_host = ENV.fetch('NGROK_HOST', ENV.fetch('URL_HOST', 'http://my.lvh.me'))
default_url_options[:host] = app_host
default_url_options[:protocol] = app_host.to_s.starts_with?('https') ? 'https' : 'http'

Rails.application.routes.default_url_options = default_url_options

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports. Conceal error pages
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local
  # config.active_storage.service = :amazon
  # config.paperclip_defaults = {
  #   :storage => :s3,
  #   :s3_host_name => 's3.ap-south-1.amazonaws.com', # Not working
  #   :s3_credentials => {
  #     :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  #     :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
  #     :s3_region => ENV['AWS_REGION']
  #   },
  #   :bucket => ENV['AWS_S3_BUCKET_NAME']
  # }

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.perform_caching = false

  if ENV['SMTP_MAILHOG'].present?
    config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }
    config.action_mailer.smtp_settings   = { address: ENV.fetch('SMTP_MAILHOG',"localhost"), port: 1025, domain: 'lvh.me' }
    config.action_mailer.default_options = { from: 'info@lvh.me', reply_to: 'noreply@lvh.me' }
  else
    config.action_mailer.default_url_options = { :host => 'localhost:3000', protocol: 'http' }
    config.action_mailer.smtp_settings   = {
      address:        ENV["SMTP_ADDRESS"],
      port:           587,
      domain:         ENV["SMTP_DOMAIN"],
      user_name:      ENV["SMTP_USER"],
      password:       ENV["SMTP_PASSWORD"],
      authentication: 'plain',
      enable_starttls_auto: true
    }
  end

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.hosts << "my.lvh.me"
  config.hosts << "ph.lvh.me"
  config.hosts << /[a-z0-9]+\.ngrok\.io/
end
