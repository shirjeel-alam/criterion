class AddInstituteAccountToCriterionAccounts < ActiveRecord::Migration
  def change
    add_column :criterion_accounts, :institute_account, :boolean, :default => false

    CriterionAccount.reset_column_information
    CriterionAccount.create!(:institute_account => true)
  end
end
