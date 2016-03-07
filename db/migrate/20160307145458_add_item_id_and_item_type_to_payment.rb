class AddItemIdAndItemTypeToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :item_id, :integer
    add_column :payments, :item_type, :string
  end
end
