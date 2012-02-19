class AddPaidOnToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :paid_on, :date
  end
end
