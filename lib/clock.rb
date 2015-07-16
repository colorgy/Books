require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)

require 'clockwork'

module Clockwork
  configure do |config|
    config[:logger] = Rails.logger
  end

  every(3.hours, 'course.sync') { CourseSyncWorker.perform_async }
end
