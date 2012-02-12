class AccountEntry < ActiveRecord::Base
	CREDIT, DEBIT = true, false
	
	belongs_to :criterion_account
end
