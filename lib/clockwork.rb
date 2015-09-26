require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(1.hour, 'criterion_report.refresh') { ScheduleTask.delay.criterion_report_refresh }
  every(1.hour, 'course_and_enrollment.refresh') { ScheduleTask.delay.course_and_enrollment_refresh }
  every(1.week, 'sms_and_mail.delete') { ScheduleTask.delay.sms_and_email_cleanup }
  every(2.minutes, 'send_sms.test' ) { ScheduleTask.delay.send_sms_test }
end