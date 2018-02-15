require 'spec_helper'

module Changed
  RSpec.describe Association, type: :model do
    it do
      should belong_to :audit
      should belong_to :associated
      should validate_presence_of :name
    end
  end
end
