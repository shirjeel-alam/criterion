ActiveAdmin.register CriterionSms do
	menu parent: 'More Menus', label: 'Criterion SMS', if: proc { current_admin_user.super_admin_or_partner? }

	filter :id
	filter :to
	filter :created_at, label: 'SMS SENT BETWEEN'
	
	index do
		column 'ID', sortable: :id do |sms|
			link_to(sms.id, admin_criterion_sm_path(sms))
		end
		column :to
		column :sender, sortable: :sender_id do |sms|
			sms.sender.email rescue nil
		end
		column :receiver, sortable: :receiver_id do |sms|
			receiver = sms.receiver
			if sms.receiver.is_a?(Student)
				link_to(receiver.name, admin_student_path(receiver))
			elsif sms.receiver.is_a?(Teacher)
				link_to(receiver.name, admin_teacher_path(receiver))
			end rescue nil
		end
    column :status, sortable: :status do |sms| 
      status_tag(sms.status_label, sms.status_tag)
    end
    
		default_actions	
	end

	form do |f|
		f.inputs do
			f.input :to, as: :select, multiple: true, collection: PhoneNumber.all_mobile_numbers, required: true, input_html: { class: 'chosen-select', style: 'width:77.8%;' }
			f.input :extra, as: :string, hint: 'Comma separated list of mobile numbers'
			f.input :message, required: true, hint: '300 Characters Only'
		end

		f.buttons
	end

	controller do
    before_filter :check_authorization
    
    def check_authorization
      if current_admin_user.all_other?
        if %w[index show edit update destroy].include?(action_name)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      end
    end

    def new
    	if params[:course].present?
        @course = Course.find(params[:course])
        @criterion_sms = CriterionSms.new(to: @course.phone_numbers.collect(&:second))
      elsif params[:courses].present?
        @courses = Course.find(params[:courses].collect(&:second))
        @criterion_sms = CriterionSms.new(to: @courses.collect { |course| course.phone_numbers.collect(&:second) }.flatten)
      elsif params[:teachers].present?
        @teachers = Teacher.find(params[:teachers].collect(&:second))
        @courses = @teachers.collect(&:courses).flatten
        @numbers = (@teachers.collect { |teacher| teacher.phone_numbers.mobile.first.number if teacher.phone_numbers.mobile.first.present? }.compact.uniq + @courses.collect { |course| course.phone_numbers.collect(&:second) }.flatten).flatten.uniq
        @criterion_sms = CriterionSms.new(to: @numbers )
      else
        @criterion_sms = current_admin_user.sent_messages.build
      end
    end

    def create
      @criterion_sms = CriterionSms.new(to: CriterionSms::DEFAULT_VALID_MOBILE_NUMBER, message: params[:criterion_sms][:message])

      if @criterion_sms.valid?
        receipients = params[:criterion_sms][:to]
        receipients << params[:criterion_sms][:extra].split(',') if params[:criterion_sms][:extra].present?
        receipients = receipients.flatten
        receipients = receipients.reject(&:blank?)

        successful_count = 0
        total_count = receipients.count
        receipients.each do |receipient|
          sms_data = { to: receipient, message: params[:criterion_sms][:message] }

          if current_admin_user.user.present?
            @criterion_sms = current_admin_user.user.sent_messages.build(sms_data)
          else
            @criterion_sms = current_admin_user.sent_messages.build(sms_data)
          end

          if @criterion_sms.save
            successful_count += 1 if @criterion_sms.successful?
          end
        end

        flash[:notice] = "SMS sent to #{successful_count} of #{total_count} receipients"
        redirect_to admin_criterion_sms_senders_path
      else
        @criterion_sms.to = params[:criterion_sms][:to]
        render :new
      end
    end
  end
end
