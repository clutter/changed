require 'spec_helper'

describe Changed do
  let(:changer) { create(:user) }
  let(:timestamp) { Time.now }

  describe '.config' do
    around do |example|
      backup_default_changer_proc = Changed.config.default_changer_proc
      Changed.config.default_changer_proc = -> { changer }
      example.run
    ensure
      Changed.config.default_changer_proc = backup_default_changer_proc
    end

    it 'uses the a "default_changer_proc" if no changer is specified' do
      expect { create(:widget) }.to change { Changed::Audit.where(changer: changer).count }
    end
  end

  describe '.perform' do
    it 'allows modifying the changer via a block then reverts' do
      original_changer = double(:changer)
      modified_changer = double(:changer)

      Changed.changer = original_changer
      Changed.perform(changer: modified_changer) do
        expect(Changed.changer).to eql(modified_changer)
      end
      expect(Changed.changer).to eql(original_changer)
    end

    it 'allows modifying the timestamp via a block then reverts' do
      original_timestamp = double(:timestamp)
      modified_timestamp = double(:timestamp)

      Changed.timestamp = original_timestamp
      Changed.perform(timestamp: modified_timestamp) do
        expect(Changed.timestamp).to eql(modified_timestamp)
      end
      expect(Changed.timestamp).to eql(original_timestamp)
    end

    it 'properly tracks the changer and timestamp to an audit for anything executed within the block' do
      expect {
        Changed.perform(changer: changer, timestamp: timestamp) { create(:widget) }
      }.to change { Changed::Audit.where(changer: changer, timestamp: timestamp).count }
    end
  end
end
