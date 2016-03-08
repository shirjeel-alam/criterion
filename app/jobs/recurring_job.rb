class RecurringJob
  include SuckerPunch::Job

  def perform(task)
    case task
    when 1
      SuckerPunch.logger.info "Task 1: CriterionReportRefresh, Time: #{Time.now}"
      ScheduleTask.criterion_report_refresh
      SuckerPunch.logger.info "Task 1 - Completed"
    when 2
      SuckerPunch.logger.info "Task 2: CourseEnrollmentRefresh, Time: #{Time.now}"
      ScheduleTask.course_and_enrollment_refresh
      SuckerPunch.logger.info "Task 2 - Completed"
    when 3
      SuckerPunch.logger.info "Task 3: SmsEmailCleanup, Time: #{Time.now}"
      ScheduleTask.sms_and_email_cleanup
      SuckerPunch.logger.info "Task 3 - Completed"
    when 4
      SuckerPunch.logger.info "Task 4: ActionRequestInvalidReject, Time: #{Time.now}"
      ScheduleTask.action_request_invalid_reject
      SuckerPunch.logger.info "Task 4 - Completed"
    end
  end
end
