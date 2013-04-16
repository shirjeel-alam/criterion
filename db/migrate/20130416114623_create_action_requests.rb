class CreateActionRequests < ActiveRecord::Migration
  def change
    create_table :action_requests do |t|
      t.string :action
      t.belongs_to :requested_by
      t.belongs_to :facilitated_by
      t.integer :action_item_id
      t.string :action_item_type
      t.string :state

      t.timestamps
    end
    add_index :action_requests, :requested_by_id
    add_index :action_requests, :facilitated_by_id
  end
end
