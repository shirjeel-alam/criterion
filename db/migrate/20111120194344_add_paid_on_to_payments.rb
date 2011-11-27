class AddPaidOnToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :paid_on, :date
    
    Payment.reset_column_information
    Payment.find_each do |payment|
      payment.update_attribute(:paid_on, Date.today) if payment.paid?
    end
  end
end
