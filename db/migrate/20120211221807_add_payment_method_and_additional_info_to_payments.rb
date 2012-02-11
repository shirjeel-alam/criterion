class AddPaymentMethodAndAdditionalInfoToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_method, :integer
    add_column :payments, :additional_info, :text

    Payment.reset_column_information
    Payment.update_all(:payment_method => Payment::CASH)
  end
end
