class AddCategoryIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :category_id, :integer
  end
end
