ActiveAdmin.register Enrollment do
  menu :priority => 2, :if => proc { current_admin_user.super_admin? || current_admin_user.admin? }
  
  filter :id
  filter :course
  filter :student
  
  index do
    column 'ID', :sortable => :id do |enrollment|
      link_to(enrollment.id, admin_enrollment_path(enrollment))
    end
    column :student do |enrollment|
      enrollment.student.name rescue nil
    end
    column :course do |enrollment|
      enrollment.course.name rescue nil
    end
    column :teacher do |enrollment|
      enrollment.course.teacher.name
    end
    column :session do |enrollment|
      enrollment.course.session.label rescue nil
    end
    column :start_date, :sortable => :start_date do |enrollment|
      date_format(enrollment.start_date)
    end
    column :status, :sortable => :status do |enrollment|
      status_tag(enrollment.status_label, enrollment.status_tag)
    end
      
    default_actions
  end
  
  form :partial => 'form'
  
  show :title => :title do
    panel 'Enrollment Details' do
      attributes_table_for enrollment do
        row(:id) { enrollment.id }
        row(:student) { link_to(enrollment.student.name, admin_student_path(enrollment.student)) rescue nil }
        row(:course) { link_to(enrollment.course.name, admin_course_path(enrollment.course)) rescue nil }
        row(:teacher) { link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
        row(:session) { link_to(enrollment.course.session.label, admin_session_path(enrollment.course.session)) rescue nil }
        row(:start_date) { date_format(enrollment.start_date) }
        row(:status) { status_tag(enrollment.status_label, enrollment.status_tag) }
      end
    end
    
    panel 'Payments' do
      table_for enrollment.payments.order(:id) do |t|
        t.column(:id) { |payment| link_to(payment.id, admin_payment_path(payment)) }
        t.column(:period) { |payment| payment.period_label}
        t.column(:gross_amount) { |payment| number_to_currency(best_in_place_if(current_admin_user.super_admin? && payment.due?, payment, :amount, :type => :input, :path => [:admin, payment]), :unit => 'Rs. ', :precision => 0) }
        t.column(:discount) { |payment| number_to_currency(best_in_place_if(current_admin_user.super_admin? && payment.due?, payment, :discount, :type => :input, :path => [:admin, payment]), :unit => 'Rs. ', :precision => 0) }
        t.column(:net_amount) { |payment| number_to_currency(payment.net_amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |payment| status_tag(payment.status_label, payment.status_tag) }
        t.column(:actions) do |payment| 
          ul do
            if payment.due?
              li span link_to('Make Payment', pay_admin_payment_path(payment), :method => :put)
              li span link_to('Void Payment', void_admin_payment_path(payment), :method => :put)
            elsif payment.paid?
              li span link_to('Refund Payment', refund_admin_payment_path(payment), :method => :put)
            end
          end
        end
      end
    end

    active_admin_comments
  end
  
  controller do
    active_admin_config.clear_action_items!

    before_filter :check_authorization

    def check_authorization
      if current_admin_user.admin?
        if %w[edit destroy].include?(action_name)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      end
    end

    def new
      if params[:student_id]
        @student = Student.find(params[:student_id])
        @courses = @student.not_enrolled_courses.collect { |c| [c.label, c.id] }
        @enrollment = @student.enrollments.build
      elsif params[:course_id]
        @course = Course.find(params[:course_id])
        @students = @course.not_enrolled_students.collect { |s| [s.name, s.id] }
        @enrollment = @course.enrollments.build
      else
        @enrollment = Enrollment.new
        @courses = Course.get_active
        @students = Student.get_all
      end
    end

    def edit
      @enrollment = Enrollment.find(params[:id])
      @courses = Course.get_active
      @students = Student.get_all
    end
  end

  controller do
    
  end
  
  member_action :start, :method => :put do
    enrollment = Enrollment.find(params[:id])
    if enrollment.start!
      flash[:error] = 'Enrollment Started'
    else
      flash[:error] = 'Error Starting Enrollment'
    end
    redirect_to :action => :show
  end

  member_action :cancel, :method => :put do
    enrollment = Enrollment.find(params[:id])
    if enrollment.cancel!
      flash[:error] = 'Enrollment Cancelled'
    else
      flash[:error] = 'Error Cancelling Enrollment'
    end
    redirect_to :action => :show
  end

  member_action :refresh, :method => :put do
    Enrollment.find(params[:id]).save
    redirect_to :action => :show
  end
  
  action_item :only => :show do
    span link_to('Refresh Enrollment', refresh_admin_enrollment_path(enrollment), :method => :put)

    if enrollment.not_started?
      span link_to('Start Enrollment', start_admin_enrollment_path(enrollment), :method => :put, :confirm => 'Are you sure?')
    elsif enrollment.started?
      span link_to('Cancel Enrollment', cancel_admin_enrollment_path(enrollment), :method => :put, :confirm => 'Are you sure?')
    end
  end
end
