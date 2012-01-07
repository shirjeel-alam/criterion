class AddRefundedOnToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :refunded_on, :date
  end
end
