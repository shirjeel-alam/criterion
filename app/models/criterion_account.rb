class CriterionAccount < ActiveRecord::Base
	belongs_to :admin_user
	has_many :account_entries

	def self.institute_account
		CriterionAccount.where(:institute_account => true).first
	end

	### View Helpers ###

	def title
		"Criterion Account - #{admin_user.user.name rescue nil}"
	end
end
