if Rails.env.production?
  Sentry.init do |config|
    config.dsn = 'https://ea7acdd08da94f2b8454454cd2cf6f84@o4503977497788416.ingest.sentry.io/4503977504276480'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    config.traces_sample_rate = 1.0
    # or
    config.traces_sampler = lambda do |context|
      true
    end
  end
end
