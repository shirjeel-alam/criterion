# == Schema Information
#
# Table name: criterion_reports
#
#  id            :integer(4)      not null, primary key
#  report_date   :date
#  gross_revenue :integer(4)
#  discounts     :integer(4)
#  net_revenue   :integer(4)
#  expenditure   :integer(4)
#  balance       :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#

class CriterionReport < ActiveRecord::Base
	validates :report_date, presence: true, uniqueness: true, timeliness: { type: :date, on_or_before: lambda { Date.today } }

	before_create :calc_report_data

	def calc_report_data
    self.gross_revenue = calc_gross_revenue
    self.discounts = calc_discounts
		self.net_revenue = calc_net_revenue
		self.expenditure = calc_expenditure
		self.balance = calc_balance
	end

	def calc_gross_revenue
    payments(AccountEntry::DEBIT, [Payment::CASH, Payment::CHEQUE]).sum(:amount)
	end

	def calc_discounts
		payments(AccountEntry::DEBIT, [Payment::CASH, Payment::CHEQUE]).sum(:discount)
	end

	def calc_net_revenue
		gross_revenue - discounts
	end

	def calc_expenditure
    payments(AccountEntry::CREDIT, [Payment::CASH]).sum(:amount)
	end

	def calc_balance
		net_revenue - expenditure
	end

	def update_report_data
		calc_report_data
		self.attributes = { updated_at: Time.now }
		save
	end

	### View Helpers ###

  def balance_tag
    balance >= 0 ? :ok : :error
  end

  def title
  	"Criterion Report - #{report_date.strftime('%d %B, %Y')}"
  end

  def payments(entry_type, payment_method)
    Payment.joins(:account_entries).where('account_entries.criterion_account_id = ? AND account_entries.entry_type = ? AND payments.payment_method IN (?) AND account_entries.created_at BETWEEN ? AND ?', CriterionAccount.bank_account.id, entry_type, payment_method, report_date.beginning_of_day, report_date.end_of_day)
  end
end