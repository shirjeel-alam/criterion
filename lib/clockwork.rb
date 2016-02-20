require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  ## SuckerPunch ##
  every(1.hour, 'criterion_report.refresh') { RecurringJob.perform_async(1) }
  every(1.hour, 'course_and_enrollment.refresh') { RecurringJob.perform_async(2) }
  every(1.week, 'sms_and_mail.delete') { RecurringJob.perform_async(3) }
  every(1.day, 'action_request_invalid.reject') { RecurringJob.perform_async(4) }
end