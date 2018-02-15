class Part < ApplicationRecord
  include Changed::Auditable
  has_and_belongs_to_many :widgets
  audited :name, :sku, transformations: { sku: 'stock keeping unit' }
end
