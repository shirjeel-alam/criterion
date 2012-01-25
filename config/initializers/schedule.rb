require 'rubygems'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every '8h' do
	Course.all.map(&:update_course)
	Enrollment.all.map(&:update_enrollment)
end