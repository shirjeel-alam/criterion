# == Schema Information
#
# Table name: criterion_report_dates
#
#  id                  :integer          not null, primary key
#  report_date         :date
#  criterion_report_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class CriterionReportDateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
