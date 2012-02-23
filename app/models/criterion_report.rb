class CriterionReport < ActiveRecord::Base
	validates :report_date, :presence => true, :uniqueness => true, :timeliness => { :type => :date, :on_or_before => lambda { Date.today } }

	before_create :calc_report_data

	def calc_report_data
		self.gross_revenue = calc_gross_revenue
		self.discounts = calc_discounts
		self.net_revenue = calc_net_revenue

		self.expenditure = calc_expenditure
		self.balance = calc_balance
	end

	def calc_gross_revenue
		Payment.debit.paid.cash_or_cheque.on(report_date).sum(:amount) rescue nil
	end

	def calc_discounts
		Payment.debit.paid.cash_or_cheque.on(report_date).sum(:discount) rescue nil
	end

	def calc_net_revenue
		(gross_revenue - discounts) rescue nil
	end

	def calc_expenditure
		Payment.credit.paid.cash.on(report_date).sum(:amount) rescue nil
	end

	def calc_balance
		(net_revenue - expenditure) rescue nil
	end

	def update_report_data
		calc_report_data
		self.attributes = { :updated_at => Time.now }
		save
	end

	### View Helpers ###

  def balance_tag
    balance >= 0 ? :ok : :error
  end

  def title
  	"Criterion Report - #{report_date.strftime('%d %B, %Y')}"
  end
end
