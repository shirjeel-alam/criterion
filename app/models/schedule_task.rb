class ScheduleTask
  def self.sms_and_email_cleanup
    ActiveRecord::Base.connection_pool.with_connection do
      date = Time.current.to_date
      CriterionSms.where('created_at < ?', date.advance(weeks: -1).beginning_of_day).destroy_all
      CriterionMail.where('created_at < ?', date.advance(weeks: -1).beginning_of_day).destroy_all
    end
  end

  def self.criterion_report_refresh
    ActiveRecord::Base.connection_pool.with_connection do
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
  end

  def self.course_and_enrollment_refresh
    #TODO: Exclude completed courses and enrollments
    ActiveRecord::Base.connection_pool.with_connection do
      Course.all.map(&:update_course)
      Enrollment.all.map(&:update_enrollment)
    end
  end

  def self.send_sms_test
    CriterionSms.send_test_sms
  end

  def self.action_request_invalid_reject
    ActionRequest.pending.find_each do |ar|
      ar.reject_request!(AdminUser.find_by_email('admin@criterion.edu')) if ar.action_item.blank?
    end
  end
end
