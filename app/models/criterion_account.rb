# == Schema Information
#
# Table name: criterion_accounts
#
#  id              :integer(4)      not null, primary key
#  admin_user_id   :integer(4)
#  initial_balance :integer(4)      default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  account_type    :integer(4)
#

class CriterionAccount < ActiveRecord::Base
	BANK, CRITERION, TEACHER, STAFF, PARTNER = 0, 1, 2, 3, 4

	belongs_to :admin_user
	has_many :account_entries

	before_create :set_account_type

	validates :admin_user_id, uniqueness: true, allow_nil: true

	def set_account_type
		case admin_user.role
	  	when AdminUser::SUPER_ADMIN
	  		self.account_type = STAFF
	  	when AdminUser::ADMIN
	  		self.account_type = STAFF
	  	when AdminUser::TEACHER
	  		self.account_type = TEACHER
      when AdminUser::STAFF
        self.account_type = STAFF
      when AdminUser::PARTNER
        self.account_type = PARTNER
  	end if admin_user.present?
	end

	def balance
		case account_type
		when BANK
			account_entries.debit.sum(:amount) - account_entries.credit.sum(:amount) + initial_balance
		else
			account_entries.credit.sum(:amount) - account_entries.debit.sum(:amount) + initial_balance
		end
	end

	def bank_account?
		self == CriterionAccount.bank_account
	end

	def criterion_account?
		self == CriterionAccount.criterion_account
	end

	### Class Methods ###

	def self.accounts(exlude_account = nil)
		CriterionAccount.all.collect { |account| [account.title, account.id] unless account == exlude_account || account == CriterionAccount.bank_account }.compact
	end

	def self.bank_account
		CriterionAccount.find_by_account_type(BANK)
	end

	def self.criterion_account
		CriterionAccount.find_by_account_type(CRITERION)
	end

	### View Helpers ###

	def title
		if admin_user.present?
			"#{account_type_label} Account - #{admin_user.user.name rescue nil}"
		else
			"#{account_type_label} Account"
		end
	end

	def account_type_label
		case account_type
			when BANK
				'Bank'
			when CRITERION
				'Criterion'
			when TEACHER
				'Teacher'
			when STAFF
				'Staff'
			when PARTNER
				'Partner'
		end
	end

	### View Helpers ###

	def initial_balance_tag
    initial_balance >= 0 ? :ok : :error
  end

  def balance_tag
    balance >= 0 ? :ok : :error
  end
end
