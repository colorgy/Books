require 'rails_helper'

RSpec.shared_examples "an acts_as_paranoid model" do
  let(:thing) { create(described_class) }

  it "soft deletes itself on destroy" do
    thing.destroy
    thing.reload
    expect(thing.deleted_at).not_to be_nil
    expect { described_class.find(thing.id) }.to raise_error
    expect(described_class.with_deleted.find(thing.id)).not_to be_nil
  end

  describe "#really_destroy!" do
    it "really destroys an instance" do
      thing.really_destroy!
      expect { thing.reload }.to raise_error
    end
  end

  describe ".with_deleted" do
    it "includes the deleted records" do
      thing.destroy
      expect(described_class.all).not_to include(thing)
      expect(described_class.with_deleted.all).to include(thing)
    end
  end
end
