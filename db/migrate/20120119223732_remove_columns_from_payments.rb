class RemoveColumnsFromPayments < ActiveRecord::Migration
  def up
  	remove_column :payments, :paid_on
    remove_column :payments, :refunded_on
  end

  def down
  	add_column :payments, :paid_on, :date
  	add_column :payments, :refunded_on, :date
  end
end
