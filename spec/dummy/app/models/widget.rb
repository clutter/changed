class Widget < ApplicationRecord
  include Changed::Auditable
  belongs_to :vendor
  has_and_belongs_to_many :parts
  audited :name, :restricted, :price, :quantity, :available, :vendor, :parts
end
