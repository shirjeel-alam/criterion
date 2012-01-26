ActiveAdmin.register CriterionSms do
	menu :parent => 'More Menus', :label => 'Criterion SMS', :if => proc { current_admin_user.super_admin? }

	filter :id
	filter :to
	filter :created_at, :label => 'SMS SENT BETWEEN'
	
	index do
		column 'ID', :sortable => :id do |sms|
			link_to(sms.id, admin_criterion_sm_path(sms))
		end
		column :to
		column :sender, :sortable => :sender_id do |sms|
			sms.sender.email rescue nil
		end
		column :receiver, :sortable => :receiver_id do |sms|
			receiver = sms.receiver
			if sms.receiver.is_a?(Student)
				link_to(receiver.name, admin_student_path(receiver))
			elsif sms.receiver.is_a?(Teacher)
				link_to(receiver.name, admin_teacher_path(receiver))
			end rescue nil
		end
		
		default_actions	
	end

	form do |f|
		f.inputs do
			f.input :to, :as => :select, :multiple => true, :collection => PhoneNumber.all_mobile_numbers, :required => true, :input_html => { :class => 'chosen-select', :style => 'width:77.8%;' }
			#f.input :to
			f.input :message
		end

		f.buttons
	end

	# show

	controller do
    before_filter :check_authorization
    
    def check_authorization
      unless current_admin_user.super_admin?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end

    def new
    	if params[:course].present?
        @course = Course.find(params[:course])
        @criterion_sms = CriterionSms.new(:to => @course.phone_numbers.collect(&:second))
      elsif params[:courses].present?
        @courses = Course.find(params[:courses].collect(&:second))
        @criterion_sms = CriterionSms.new(:to => @courses.collect { |course| course.phone_numbers.collect(&:second) }.flatten)
      elsif params[:teachers].present?
        @teachers = Teacher.find(params[:teachers].collect(&:second))
        @criterion_sms = CriterionSms.new(:to => @teachers.collect { |teacher| teacher.phone_numbers.mobile.first.number if teacher.phone_numbers.mobile.first.present? }.compact.uniq )
      else
        @criterion_sms = current_admin_user.sent_messages.build
      end
    end

    def create
    	@criterion_sms = current_admin_user.sent_messages.build(params[:criterion_sms])

    	if @criterion_sms.save
    		if @criterion_sms.successful?
    			flash[:notice] = 'SMS successfully sent'
        	redirect_to admin_criterion_sm_path(@criterion_sms)
    		else
    			flash[:error] = 'Error sending SMS'
        	redirect_to root_path
    		end
    	else
    		render :new
    	end
    end
  end
end
