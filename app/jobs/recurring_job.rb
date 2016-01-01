class RecurringJob
  include SuckerPunch::Job

  def perform(task)
    case task
    when 1
      ScheduleTask.criterion_report_refresh
    when 2
      ScheduleTask.course_and_enrollment_refresh
    when 3
      ScheduleTask.sms_and_email_cleanup
    when 4
      ScheduleTask.send_sms_test
    end
  end
end