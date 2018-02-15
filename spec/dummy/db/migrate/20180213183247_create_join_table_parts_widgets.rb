class CreateJoinTablePartsWidgets < ActiveRecord::Migration[5.1]
  def change
    create_join_table :parts, :widgets do |t|
      t.index %i[part_id widget_id]
      t.index %i[widget_id part_id]
    end
  end
end
