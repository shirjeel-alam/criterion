require 'rubygems'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every '5s' do
  Rails.logger.info '*** RUFUS SCHEDULER ***'
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

	Course.all.map(&:update_course)
	Enrollment.all.map(&:update_enrollment)
end

scheduler.every '1w' do
  CriterionSms.where('created_at < ?', Date.today.advance(weeks: -1).beginning_of_day).destroy_all
  CriterionMail.where('created_at < ?', Date.today.advance(weeks: -1).beginning_of_day).destroy_all
end
