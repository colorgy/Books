require 'rails_helper'

RSpec.describe BatchCodeService, :type => :service do
  describe ".current_year" do
    it "returns the current semester year" do
      expect(BatchCodeService.current_year).to eq((Time.now.month > 6) ? Time.now.year : Time.now.year - 1)
    end
  end

  describe ".current_term" do
    it "returns the current term" do
      expect(BatchCodeService.current_term).to eq((Time.now.month > 6) ? 1 : 2)
    end
  end

  describe ".current_batch" do
    before do
      Settings.order_batch = '08'
    end

    it "returns the current batch" do
      expect(BatchCodeService.current_batch).to eq("#{BatchCodeService.current_year}-#{BatchCodeService.current_term}-#{Settings.order_batch}")
    end
  end

  describe ".generate_group_code" do
    before do
      Settings.order_batch = '07'
    end

    it "generates an current group code if batch not given" do
      code = BatchCodeService.generate_group_code('NTU', 1337, 7331)
      expect(code).to eq("#{BatchCodeService.current_batch}-NTU-1337-7331")
    end

    it "generates an group code in batch if batch is given" do
      code = BatchCodeService.generate_group_code('NTU', 1337, 7331, batch: '2010-1-1')
      expect(code).to eq("2010-1-1-NTU-1337-7331")
    end
  end
end
