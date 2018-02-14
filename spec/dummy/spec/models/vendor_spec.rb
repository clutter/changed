require 'spec_helper'

RSpec.describe Vendor, type: :model do
  it do
    should have_many :widgets
  end
end
