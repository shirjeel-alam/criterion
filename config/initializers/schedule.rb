require 'rubygems'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every '8h' do
	Course.all.map(&:update_course)
	Enrollment.all.map(&:update_enrollment)
end

scheduler.every '2h' do
	cr = CriterionReport.find_or_create_by_report_date(Date.today)
	cr.update_report_data
end