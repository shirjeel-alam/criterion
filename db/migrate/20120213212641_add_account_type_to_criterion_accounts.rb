class AddAccountTypeToCriterionAccounts < ActiveRecord::Migration
  def change
    add_column :criterion_accounts, :account_type, :integer

    CriterionAccount.reset_column_information
    
    CriterionAccount.create(:account_type => CriterionAccount::BANK)
    CriterionAccount.create(:account_type => CriterionAccount::CRITERION)

    AdminUser.find_each do |user|
    	user.build_criterion_account.save
    end
  end
end
