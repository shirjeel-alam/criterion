class AccountEntry < ActiveRecord::Base
	CREDIT, DEBIT = true, false
	
	belongs_to :criterion_account
	belongs_to :payment

	scope :credit, where(:entry_type => CREDIT)
  scope :debit, where(:entry_type => DEBIT)

  def credit?
    entry_type == CREDIT
  end

  def debit?
    entry_type == DEBIT
  end

	### View Helpers ###

	def entry_type_label
    entry_type ? 'Credit' : 'Debit'
  end

  def entry_type_tag
    entry_type ? :ok : :warning
  end
end
