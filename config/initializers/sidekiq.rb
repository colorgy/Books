# Sidekiq configuration

# Logger
case ENV['LOGGER']
when 'stdout'
  require 'rails_stdout_logging/rails'
  Sidekiq::Logging.logger = RailsStdoutLogging::Rails.heroku_stdout_logger
when 'remote'
  # Send logs to a remote server
  if !ENV['REMOTE_LOGGER_HOST'].blank? && !ENV['REMOTE_LOGGER_PORT'].blank?
    app_name = ENV['APP_NAME'] || Rails.application.class.parent_name
    Sidekiq::Logging.logger = \
      RemoteSyslogLogger.new(ENV['REMOTE_LOGGER_HOST'], ENV['REMOTE_LOGGER_PORT'],
                             local_hostname: "#{app_name.underscore}-#{Socket.gethostname}".gsub(' ', '_'),
                             program: ('sidekiq-' + Rails.application.class.parent_name.underscore))
  end
end

# Redis
redis_url = (ENV['REDIS_URL'].present? && ENV['REDIS_URL']) ||
            (ENV['REDISCLOUD_URL'].present? && ENV['REDISCLOUD_URL']) ||
            'redis://localhost:6379'
app_name = (ENV['APP_NAME'] || Rails.application.class.parent_name).underscore.gsub(' ', '_')

redis_conn = lambda do
  conn = Redis.new(url: redis_url)
  Redis::Namespace.new(app_name, redis: conn)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(&redis_conn)
end

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(&redis_conn)
end
