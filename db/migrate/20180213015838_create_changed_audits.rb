class CreateChangedAudits < ActiveRecord::Migration[5.1]
  def change
    create_table :changed_audits do |t|
      t.references :changer, polymorphic: true, null: true, index: true
      t.references :audited, polymorphic: true, null: false, index: true
      t.jsonb :changeset, default: {}, null: false
      t.string :event, null: false
      t.datetime :timestamp, null: false

      t.timestamps
    end
  end
end
