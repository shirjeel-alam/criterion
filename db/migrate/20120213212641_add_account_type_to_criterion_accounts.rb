class AddAccountTypeToCriterionAccounts < ActiveRecord::Migration
  def change
    add_column :criterion_accounts, :account_type, :integer
  end
end
