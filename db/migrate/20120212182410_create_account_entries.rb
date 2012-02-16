class CreateAccountEntries < ActiveRecord::Migration
  def change
    create_table :account_entries do |t|
    	t.integer :criterion_account_id
      t.integer :payment_id
      t.integer :amount
      t.boolean :entry_type

      t.timestamps
    end
  end
end
