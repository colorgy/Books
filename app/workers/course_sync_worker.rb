class CourseSyncWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform
    Course.sync
  end
end
