class GroupEndCheckWorker
  include Sidekiq::Worker

  def perform
    Group.grouping.find_each do |group|
      group.end_if_deadline_passed
    end
  end
end
