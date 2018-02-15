FactoryBot.define do
  factory :widget do
    association :vendor, strategy: :build
    name 'Sprocket'
    color 'orange'
    quantity 2
    price 9.99
    available Time.now
  end
end
