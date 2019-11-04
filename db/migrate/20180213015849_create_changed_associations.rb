class CreateChangedAssociations < ActiveRecord::Migration[6.0]
  def change
    create_table :changed_associations do |t|
      t.references :audit, null: false, index: true
      t.references :associated, null: false, polymorphic: true, index: true
      t.string :name, null: false
      t.integer :kind, null: false

      t.timestamps
    end

    add_foreign_key :changed_associations, :changed_audits, column: :audit_id
  end
end
