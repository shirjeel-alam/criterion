class ScheduleTask
	def self.sms_and_email_cleanup
		CriterionSms.where('created_at < ?', date.advance(weeks: -1).beginning_of_day).destroy_all
		CriterionMail.where('created_at < ?', date.advance(weeks: -1).beginning_of_day).destroy_all
	end

	def self.criterion_report_refresh
		date = Time.current.to_date

    crd = CriterionReportDate.find_by_report_date(date)
    if crd.present?
      cr = crd.criterion_report
    else
      cr = CriterionReport.open.first
      cr.criterion_report_dates.create(report_date: date)
    end
    cr.update_report_data
	end

	def self.course_and_enrollment_refresh
		#TODO: Exclude completed courses and enrollments
		Course.all.map(&:update_course)
		Enrollment.all.map(&:update_enrollment)
	end

	def self.send_sms_test
		CriterionSms.send_test_sms
	end
end