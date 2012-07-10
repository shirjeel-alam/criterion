require 'rubygems'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every '50m' do
	Net::HTTP.get_response(URI.parse('http://criterion-institute.herokuapp.com/admin/login'))
end

scheduler.every '4h' do
  crd = CriterionReportDate.find_by_report_date(Date.today)
  if crd.present?
    cr = crd.criterion_report
  else
    cr = CriterionReport.open.first
    cr.criterion_report_dates.create(report_date: Date.today)
  end
	cr.update_report_data

  cmr = CriterionMonthlyReport.find_or_initialize_by_report_month(Date.today.beginning_of_month)
  cmr.save

	Course.all.map(&:update_course)
	Enrollment.all.map(&:update_enrollment)
end
