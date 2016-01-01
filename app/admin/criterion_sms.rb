ActiveAdmin.register CriterionSms do
	menu parent: 'More Menus', label: 'Criterion SMS', if: proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? }

	filter :id
	filter :to
	filter :created_at, label: 'SMS SENT BETWEEN'

  scope :all
  scope :sent
  scope :failed
	
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
      elsif sms.receiver.is_a?(Partner)
        link_to(receiver.name, admin_partner_path(receiver))
      elsif sms.receiver.is_a?(Staff)
        link_to(receiver.name, admin_staff_path(receiver))
			end rescue nil
		end
    column :status, sortable: :status do |sms| 
      status_tag(sms.status_label, sms.status_tag)
    end
    column 'API Response', sortable: :api_response do |sms|
      sms.api_response
    end
    
		default_actions	
	end

	form do |f|
		f.inputs do
			f.input :to, as: :select, multiple: true, collection: PhoneNumber.all_mobile_numbers, required: true, input_html: { class: 'chosen-select', style: 'width:77.8%;' }
			f.input :extra, as: :string, hint: 'Comma separated list of mobile numbers'
			f.input :message, required: true, hint: '160 characters remaining', input_html: { maxlength: 160 }
		end

		f.buttons
	end

	controller do
    before_filter :check_authorization
    
    def check_authorization
      if current_admin_user.all_other? && !current_admin_user.admin?
        if %w[index show edit update destroy].include?(action_name)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      end
    end

    def new
      @due_fees = (params[:due_fees] == 'true')

      if params[:courses].present?
        @courses = Course.find(params[:courses].collect(&:second))
        if @due_fees
          @courses = @courses.collect(&:id)
          @payments = Payment.due_fees(Time.current.to_date)
          @payments.reject! { |payment| payment unless @courses.include?((payment.payable.course_id rescue nil)) || payment.period.blank? }
          @numbers = @payments.collect { |payment| payment.payable.student.phone_numbers.mobile.collect(&:number) }.flatten
          @criterion_sms = CriterionSms.new(to: @numbers)
        else
          @criterion_sms = CriterionSms.new(to: @courses.collect { |course| course.phone_numbers.collect(&:second) }.flatten)
        end
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

          # @criterion_sms.save
          SmsJob.new.async.perform(2, @criterion_sms)
        end

        flash[:notice] = "SMS sent to #{total_count} recipients"
        redirect_to admin_criterion_sms_sender_path
      else
        @criterion_sms.to = params[:criterion_sms][:to]
        render :new
      end
    end
  end
end