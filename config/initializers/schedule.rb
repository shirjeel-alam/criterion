# require 'rubygems'
# require 'rufus/scheduler'

# def execute_scheduler
#   # Create your scheduler here
#   scheduler = Rufus::Scheduler.new  
#   logger = Logger.new(Rails.root.to_s + '/log/scheduler.log')

#   scheduler.every '4h' do
#     date = Time.current.to_date

#     crd = CriterionReportDate.find_by_report_date(date)
#     if crd.present?
#       cr = crd.criterion_report
#     else
#       cr = CriterionReport.open.first
#       cr.criterion_report_dates.create(report_date: date)
#     end
#     cr.update_report_data

#     Course.all.map(&:update_course)
#     Enrollment.all.map(&:update_enrollment)
#   end

#   scheduler.every '1w' do
#     date = Time.current.to_date

#     CriterionSms.where('created_at < ?', date.advance(weeks: -1).beginning_of_day).destroy_all
#     CriterionMail.where('created_at < ?', date.advance(weeks: -1).beginning_of_day).destroy_all
#   end
# end

# # Create the main logger and set some useful variables.
# main_logger = Logger.new(Rails.root.to_s + '/log/scheduler.log')
# pid_file = (Rails.root.to_s + '/tmp/pids/scheduler').to_s
# File.delete(pid_file) if FileTest.exists?(pid_file)

# if defined?(PhusionPassenger) then
#   # Passenger is starting a new process
#   PhusionPassenger.on_event(:starting_worker_process) do |forked| 
#     # If we are forked and there's no pid file (that is no lock)
#     if forked && !FileTest.exists?(pid_file) then
#       main_logger.debug "SCHEDULER START ON PROCESS #{$$}"
#       # Write the current PID on the file
#       File.open(pid_file, 'w') {
#         |f| f.write($$)
#       }

#       # Execute the scheduler
#       execute_scheduler
#     end
#   end
#   # Passenger is shutting down a process.   
#   PhusionPassenger.on_event(:stopping_worker_process) do
#     # If a pid file exists and the process which 
#     # is being shutted down is the same which holds the lock 
#     # (in other words, the process which is executing the scheduler)
#     # we remove the lock.
#     if FileTest.exists?(pid_file) then
#       if File.open(pid_file, 'r') {|f| pid = f.read.to_i} == $$ then 
#         main_logger.debug "SCHEDULER STOP ON PROCESS #{$$}"
#         File.delete(pid_file)
#       end
#     end
#   end
# else # Only execute one scheduler
#   execute_scheduler
# end

# main_logger.info 'SCHEDULER START'