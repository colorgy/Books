class PackagePaidCheckWorker
  include Sidekiq::Worker

  def perform
    Package.is_new.find_each do |package|
      package.mark_paid_if_all_paid
    end
  end
end
