FactoryBot.define do
  factory :widget do
    vendor
    name { 'Sprocket' }
    color { 'orange' }
    quantity { 2 }
    price { 9.99 }
    available { Time.current }
  end
end
