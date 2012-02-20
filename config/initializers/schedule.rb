require 'rubygems'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every '1m' do
	Net::HTTP.get_response(URI.parse('http://criterion-institute.heroku.com/admin/login'))
end

scheduler.every '4h' do
	cr = CriterionReport.find_or_create_by_report_date(Date.today)
	cr.update_report_data

	Course.all.map(&:update_course)
	Enrollment.all.map(&:update_enrollment)
end