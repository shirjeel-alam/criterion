class CreateCriterionAccounts < ActiveRecord::Migration
  def change
    create_table :criterion_accounts do |t|
      t.integer :admin_user_id
      t.integer :balance

      t.timestamps
    end

    CriterionAccount.reset_column_information
    AdminUser.find_each do |user|
    	user.build_criterion_account.save
    end
  end
end
