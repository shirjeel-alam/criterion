require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  ## SuckerPunch ##
  every(1.hour, 'criterion_report.refresh') { RecurringJob.new.async.perform(1) }
  every(1.hour, 'course_and_enrollment.refresh') { RecurringJob.new.async.perform(2) }
  every(1.week, 'sms_and_mail.delete') { RecurringJob.new.async.perform(3) }
end