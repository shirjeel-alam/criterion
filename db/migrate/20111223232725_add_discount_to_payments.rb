class AddDiscountToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :discount, :integer
  end
end
