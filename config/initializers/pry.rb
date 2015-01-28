Pry.config.prompt_name = (ENV['APP_NAME'].presence || Rails.application.class.parent_name).underscore.dasherize

unless Rails.env.development?
  old_prompt = Pry.config.prompt

  if Rails.env.production?
    env = "\001\e[0;34m\002#{Rails.env.upcase[0..2]}\001\e[0m\002"
  elsif Rails.env.staging?
    env = "\001\e[0;33m\002#{Rails.env.upcase[0..2]}\001\e[0m\002"
  else
    env = "\001\e[0;32m\002#{Rails.env.upcase[0..2]}\001\e[0m\002"
  end

  Pry.config.prompt = [
    proc { |*a| "#{env} #{old_prompt.first.call(*a)}"  },
    proc { |*a| "#{env} #{old_prompt.second.call(*a)}" }
  ]
end
