require 'spec_helper'

RSpec.describe Widget, type: :model do
  it do
    should belong_to :vendor
    should have_and_belong_to_many :parts
  end
end
