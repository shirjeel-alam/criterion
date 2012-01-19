class AddColumnsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_date, :date
  end
end
