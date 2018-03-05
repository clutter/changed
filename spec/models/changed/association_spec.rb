require 'spec_helper'

RSpec.describe Changed::Association, type: :model do
  it do
    should belong_to :audit
    should belong_to :associated
    should validate_presence_of :name
  end
end
