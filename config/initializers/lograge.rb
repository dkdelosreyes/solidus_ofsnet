Rails.application.configure do

  config.lograge.enabled = true

  # for production lograge formatter is logstash (json)
  if Rails.env.production?
    config.lograge.formatter = Lograge::Formatters::Logstash.new
  else
    config.lograge.formatter = Lograge::Formatters::KeyValue.new
  end

  config.lograge.custom_payload do |controller|
    {
      referrer:      controller.request.try(:referrer),
      host:          controller.request.host,
      spree_user_id: controller.current_spree_user.try(:id),
      remote_ip:     controller.request.try(:remote_ip),
      request_uri:   controller.request.try(:path),
      uri:           controller.request.try(:fullpath)
    }
  end

  config.lograge.custom_options = lambda do |event|
    log = {}

    if event.payload[:exception].present?
      log[:exception] = event.payload[:exception].class.to_s.red
      log[:error]     = event.payload[:exception].to_s.red
      log[:backtrace] = Rails.application.
        backtrace_exception_filter(event.payload[:exception_object].backtrace) if event.payload[:exception_object].backtrace.present?
    end

    if event.payload[:params].present?
      log[:params] = event.payload[:params].
        reject { |k| %w(controller action format).include?(k) }
    end

    log
  end

end

