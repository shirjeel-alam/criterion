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

  member_action :resend, method: :put do
    sms = CriterionSms.find(params[:id])
    if sms.send_sms
      flash[:notice] = 'Sms sent successfully'
    else
      flash[:error] = 'Error sending sms. Try again later'
    end
    redirect_to action: :show
  end

  collection_action :resend, method: :put do
    failed_sms = CriterionSms.failed
    count = 0

    failed_sms.find_each do |sms|
      count += 1 if sms.send_sms
    end

    flash[:notice] = "#{count} of #{failed_sms.count} sms sent successfully"
    redirect_to action: :index
  end

  action_item only: :show do
    if (current_admin_user.super_admin_or_partner? || current_admin_user.admin?) && !criterion_sms.status
      span link_to('Resend', resend_admin_criterion_sm_path(criterion_sms), method: :put)
    end
  end

  action_item only: :index do
    if (current_admin_user.super_admin_or_partner? || current_admin_user.admin?) && CriterionSms.failed.present?
      span link_to('Resend All', resend_admin_criterion_sms_path, method: :put)
    end
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
      @include_cancelled = (params[:include_cancelled] == 'true')

      if params[:courses].present?
        @courses = Course.find(params[:courses].collect(&:second))
        @numbers = nil

        if @due_fees
          @payments = @courses.collect { |course| course.payments.due_fees(Time.current.to_date) }.flatten
          @payments.reject! { |payment| payment if payment.payable.cancelled? rescue false } unless @include_cancelled
          @numbers = @payments.collect { |payment| payment.payable.student.phone_numbers.mobile.collect(&:number) }.flatten
        else
          @students = nil
          if @include_cancelled
            @students = @courses.collect(&:students).flatten.uniq
          else
            @students = @courses.collect { |course| course.enrollments.not_cancelled }.flatten.collect(&:student).uniq
          end
          @numbers = @students.collect { |student| student.phone_numbers.mobile.collect(&:number) }.flatten
        end

        @criterion_sms = CriterionSms.new(to: @numbers)
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

          SmsJob.perform_async(2, @criterion_sms)
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
