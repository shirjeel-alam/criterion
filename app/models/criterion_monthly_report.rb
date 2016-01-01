# == Schema Information
#
# Table name: criterion_monthly_reports
#
#  id           :integer          not null, primary key
#  report_month :date
#  revenue      :integer
#  expenditure  :integer
#  balance      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class CriterionMonthlyReport < ActiveRecord::Base
  validates :report_month, presence: true, uniqueness: true

  before_create :set_report_month
  before_save :calc_report_data

  def calc_report_data
    self.revenue = calc_revenue
    self.expenditure = calc_expenditure
    self.balance = calc_balance
  end

  def calc_revenue
    payments(AccountEntry::CREDIT).sum do |payment| 
      if payment.payable.is_a?(Enrollment)
        (payment.net_amount * (1 - payment.payable.teacher.share)).round
      else
        payment.net_amount
      end
    end
  end

  def calc_expenditure
    payments(AccountEntry::DEBIT).sum do |payment| 
      if payment.payable.is_a?(Enrollment)
        (payment.net_amount * (1 - payment.payable.teacher.share)).round
      else
        payment.net_amount
      end
    end
  end

  def calc_balance
    revenue - expenditure
  end

  def payments(entry_type)
    time_range = Range.new(report_month.beginning_of_month, report_month.end_of_month)
    Payment.joins(:account_entries).where(period: time_range).where('account_entries.criterion_account_id = ? AND account_entries.entry_type = ? AND payments.category_id != ?' , CriterionAccount.criterion_account.id, entry_type, Category.find_by_name('appropriated').id)
  end

  ### Class Methods ###

  def self.balance
    CriterionMonthlyReport.sum(:balance)
  end

  def self.balance_tag
    self.balance >= 0 ? :ok : :error
  end

  ### View Helpers ###

  def balance_tag
    balance >= 0 ? :ok : :error
  end

  def title
    "Profitability Report - #{report_month.strftime('%B %Y')}"
  end

  private

  def set_report_month
    self.report_month = report_month.beginning_of_month
  end
end