ActiveAdmin.register CriterionMail, :as => 'CriterionMailer' do
	menu :priority => 2, :if => proc { current_admin_user.super_admin? || current_admin_user.admin? }

	actions :index

	scope :courses, :default => true do |courses|
		Course.active
	end

	scope :teachers do |teachers|
		Teacher.select('*')
	end

	index do 
		render :partial => 'course_mailer', :locals => { :courses => Course.active, :teachers => Teacher.all }
	end

	controller do
		active_admin_config.clear_sidebar_sections!
		active_admin_config.clear_action_items!
	end
end