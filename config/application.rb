require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Books
  class Application < Rails::Application
    Dotenv::Railtie.load if defined? Dotenv::Railtie
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.paths.add File.join('app', 'services'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'services', '*')]

    config.active_record.raise_in_transactional_callbacks = true

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 8

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'zh-TW'

    config.action_mailer.delivery_method = (ENV['MAILER_DELIVERY_METHOD'].presence || :letter_opener).to_sym

    case ENV['LOGGER']
    when 'stdout'
      require 'rails_stdout_logging/rails'
      config.logger = RailsStdoutLogging::Rails.heroku_stdout_logger
    when 'remote'
      # Send logs to a remote server
      if !ENV['REMOTE_LOGGER_HOST'].blank? && !ENV['REMOTE_LOGGER_PORT'].blank?
        config.logger = \
        RemoteSyslogLogger.new(ENV['REMOTE_LOGGER_HOST'], ENV['REMOTE_LOGGER_PORT'],
                               local_hostname: "#{ENV['APP_NAME'].underscore}-#{Rails.application.class.parent_name.underscore}-#{Socket.gethostname}".gsub(' ', '_'),
                               program: ('rails-' + Rails.application.class.parent_name.underscore))
      end
    end
  end
end
