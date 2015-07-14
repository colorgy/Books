redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379'
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
