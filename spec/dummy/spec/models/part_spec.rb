require 'spec_helper'

RSpec.describe Part, type: :model do
  it do
    should have_and_belong_to_many :widgets
  end
end
