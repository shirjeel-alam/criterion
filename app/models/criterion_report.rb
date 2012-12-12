# == Schema Information
#
# Table name: criterion_reports
#
#  id            :integer          not null, primary key
#  gross_revenue :integer
#  discounts     :integer
#  net_revenue   :integer
#  expenditure   :integer
#  balance       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  closed        :boolean          default(FALSE)
#

class CriterionReport < ActiveRecord::Base
  attr_accessor :report_date

  has_many :criterion_report_dates, dependent: :destroy

	before_create :build_criterion_report_date, :calc_report_data

  scope :open, where(closed: false)
  scope :closed, where(closed: true)

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
    payments(AccountEntry::CREDIT, [Payment::CASH]).collect(&:net_amount).sum
	end

	def calc_balance
		net_revenue - expenditure
	end

	def update_report_data
		calc_report_data
		self.attributes = { updated_at: Time.now }
		save
	end

  def close!
    update_report_data
    update_attribute(:closed, true)
  end

  def open!
    update_attribute(:closed, false)
  end

  def self.next_report
    CriterionReport.create(report_date: (CriterionReportDate.order('report_date desc').first.report_date + 1.day))
  end

	### View Helpers ###

  def balance_tag
    balance >= 0 ? :ok : :error
  end

  def status_label
    closed? ? 'Closed' : 'Open'
  end

  def status_tag
    closed? ? :error : :ok
  end

  def title
    report_dates = criterion_report_dates.collect(&:report_date).sort
  	"Criterion Report: #{report_dates.first.strftime('%d %B, %Y')} - #{report_dates.last.strftime('%d %B, %Y')}"
  end

  def payments(entry_type, payment_method)
    report_dates = criterion_report_dates.collect(&:report_date).sort
    Payment.joins(:account_entries).where('account_entries.criterion_account_id = ? AND account_entries.entry_type = ? AND payments.payment_method IN (?) AND account_entries.created_at BETWEEN ? AND ?', CriterionAccount.bank_account.id, entry_type, payment_method, report_dates.first.beginning_of_day, report_dates.last.end_of_day)
  end

  private

  def build_criterion_report_date
    crd = criterion_report_dates.build(report_date: report_date)
    crd.valid?
  end
end
