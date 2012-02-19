class AddPaymentMethodAndAdditionalInfoToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_method, :integer
    add_column :payments, :additional_info, :text
  end
end
