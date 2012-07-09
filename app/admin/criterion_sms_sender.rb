ActiveAdmin.register CriterionSms, as: 'Criterion SMS Sender' do
	menu label: 'Send SMS', parent: 'Criterion', priority: 2, if: proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? || current_admin_user.teacher? }

	actions :index

	scope :courses, default: true do |courses|
		Course.order('id desc')
	end

	scope :teachers do |teachers|
		Teacher.order('id desc')
	end

	index do 
		div render partial: 'criterion_sms_sender', locals: { courses: Course.order('id desc'), teachers: Teacher.order('id desc'), scope: params[:scope] }
	end

	controller do
		active_admin_config.clear_sidebar_sections!
		active_admin_config.clear_action_items!
	end
end