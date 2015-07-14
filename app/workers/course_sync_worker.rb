class CourseSyncWorker
  include Sidekiq::Worker

  def perform
    Course.sync
  end
end
