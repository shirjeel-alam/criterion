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
		Payment.credit.paid.on(report_date).sum(:amount)
	end

	def calc_discounts
		Payment.credit.paid.on(report_date).sum(:discount)
	end

	def calc_net_revenue
		(gross_revenue - discounts) rescue nil
	end

	def calc_expenditure
		Payment.debit.paid.on(report_date).sum(:amount)
	end

	def calc_balance
		(net_revenue - expenditure) rescue nil
	end

	def update_report_date
		calc_report_data
		save
	end

	### View Helpers ###

  def balance_tag
    balance >= 0 ? :ok : :error
  end
end
