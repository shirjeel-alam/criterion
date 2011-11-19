class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :payable_id
      t.string :payable_type
      t.date :period
      t.integer :amount
      t.boolean :status
      t.boolean :payment_type

      t.timestamps
    end
  end
end
