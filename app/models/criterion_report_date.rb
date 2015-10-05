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

class CriterionReportDate < ActiveRecord::Base
  belongs_to :criterion_report
  validates :report_date, presence: true, uniqueness: true, timeliness: { type: :date, on_or_before: lambda { Date.tomorrow } }
end