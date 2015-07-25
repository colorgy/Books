class GroupReadyCheckWorker
  include Sidekiq::Worker

  def perform
    Group.grouping.find_each do |group|
      group.automatically_be_ready_or_fail
    end
  end
end
