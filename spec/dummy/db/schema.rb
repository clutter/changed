# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_02_13_183247) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "changed_associations", force: :cascade do |t|
    t.bigint "audit_id", null: false
    t.string "associated_type", null: false
    t.bigint "associated_id", null: false
    t.string "name", null: false
    t.integer "kind", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["associated_type", "associated_id"], name: "index_changed_associations_on_associated_type_and_associated_id"
    t.index ["audit_id"], name: "index_changed_associations_on_audit_id"
  end

  create_table "changed_audits", force: :cascade do |t|
    t.string "changer_type"
    t.bigint "changer_id"
    t.string "audited_type", null: false
    t.bigint "audited_id", null: false
    t.jsonb "changeset", default: {}, null: false
    t.string "event", null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["audited_type", "audited_id"], name: "index_changed_audits_on_audited_type_and_audited_id"
    t.index ["changer_type", "changer_id"], name: "index_changed_audits_on_changer_type_and_changer_id"
  end

  create_table "parts", force: :cascade do |t|
    t.string "sku", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "parts_widgets", id: false, force: :cascade do |t|
    t.bigint "part_id", null: false
    t.bigint "widget_id", null: false
    t.index ["part_id", "widget_id"], name: "index_parts_widgets_on_part_id_and_widget_id"
    t.index ["widget_id", "part_id"], name: "index_parts_widgets_on_widget_id_and_part_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "widgets", force: :cascade do |t|
    t.bigint "vendor_id"
    t.string "name", null: false
    t.string "color", null: false
    t.boolean "restricted", default: false, null: false
    t.decimal "price", default: "0.0", null: false
    t.integer "quantity", default: 0, null: false
    t.datetime "available", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["vendor_id"], name: "index_widgets_on_vendor_id"
  end

  add_foreign_key "changed_associations", "changed_audits", column: "audit_id"
  add_foreign_key "widgets", "vendors"
end
