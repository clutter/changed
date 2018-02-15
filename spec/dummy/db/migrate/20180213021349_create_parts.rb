class CreateParts < ActiveRecord::Migration[5.1]
  def change
    create_table :parts do |t|
      t.string :sku, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
