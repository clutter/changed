class CreateWidgets < ActiveRecord::Migration[5.1]
  def change
    create_table :widgets do |t|
      t.references :vendor
      t.string :name, null: false
      t.string :color, null: false
      t.boolean :restricted, null: false, default: false
      t.decimal :price, null: false, default: 0.0
      t.integer :quantity, null: false, default: 0
      t.timestamp :available, null: false

      t.timestamps
    end

    add_foreign_key :widgets, :vendors
  end
end
