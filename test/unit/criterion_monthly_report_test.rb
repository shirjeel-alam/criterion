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

require 'test_helper'

class CriterionMonthlyReportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
