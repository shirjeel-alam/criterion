class CreateCriterionAccounts < ActiveRecord::Migration
  def change
    create_table :criterion_accounts do |t|
      t.integer :admin_user_id
      t.integer :balance

      t.timestamps
    end
  end
end
