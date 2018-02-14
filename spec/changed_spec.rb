require 'spec_helper'

describe Changed do
  let(:changer) { create(:user) }
  let(:timestamp) { Time.now }

  describe '.config' do
    it 'allows modifying the changer via a block then reverts' do
      original_changer = double(:changer)
      modified_changer = double(:changer)

      Changed.changer = original_changer
      Changed.config(changer: modified_changer) do
        expect(Changed.changer).to eql(modified_changer)
      end
      expect(Changed.changer).to eql(original_changer)
    end

    it 'allows modifying the timestamp via a block then reverts' do
      original_timestamp = double(:timestamp)
      modified_timestamp = double(:timestamp)

      Changed.timestamp = original_timestamp
      Changed.config(timestamp: modified_timestamp) do
        expect(Changed.timestamp).to eql(modified_timestamp)
      end
      expect(Changed.timestamp).to eql(original_timestamp)
    end

    it 'properly tracks the changer and timestamp to an audit for anything executed within the block' do
      expect {
        Changed.config(changer: changer, timestamp: timestamp) { create(:widget) }
      }.to change { Changed::Audit.where(changer: changer, timestamp: timestamp).count }
    end
  end
end
