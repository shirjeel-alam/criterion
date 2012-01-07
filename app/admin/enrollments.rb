ActiveAdmin.register Enrollment do
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
        t.column(:gross_amount) { |payment| number_to_currency(best_in_place(payment, :amount, :type => :input, :path => [:admin, payment]), :unit => 'Rs. ', :precision => 0) }
        t.column(:discount) { |payment| number_to_currency(best_in_place(payment, :discount, :type => :input, :path => [:admin, payment]), :unit => 'Rs. ', :precision => 0) }
        t.column(:net_amount) { |payment| number_to_currency(payment.net_amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |payment| status_tag(payment.status_label, payment.status_tag) }
        t.column(:paid_on) { |payment| payment.date_label }
        t.column(:actions) { |payment| link_to('Make Payment', pay_admin_payment_path(payment), :method => :put) unless payment.paid? }
      end
    end
  end
  
  controller do
    active_admin_config.clear_action_items!

    def new
      if params[:student_id]
        @student = Student.find(params[:student_id])
        @enrollment = @student.enrollments.build
        @courses = @student.not_enrolled_courses.collect { |c| [c.label, c.id] }
      elsif params[:course_id]
        @course = Course.find(params[:course_id])
        @enrollment = @course.enrollments.build
        @students = @course.not_enrolled_students.collect { |s| [s.name, s.id] }
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
  
  member_action :cancel, :method => :put do
    enrollment = Enrollment.find(params[:id])
    enrollment.attributes = { :status => Enrollment::CANCELLED, :enrollment_date => Date.today, :enrollment_date_for => Enrollment::CANCELLATION }
    if enrollment.save
      enrollment.void_payments
      flash[:error] = 'Enrollment Cancelled'
    else
      flash[:error] = 'Error Cancelling Enrollment'
    end
    redirect_to :action => :show
  end

  member_action :refresh, :method => :put do
    enrollment = Enrollment.find(params[:id])
    enrollment.save
    redirect_to :action => :show
  end
  
  action_item :only => :show do
    span link_to('Refresh Enrollment', refresh_admin_enrollment_path(enrollment), :method => :put)
    span link_to('Cancel Enrollment', cancel_admin_enrollment_path(enrollment), :method => :put, :confirm => 'Are you sure?') unless [Enrollment::CANCELLED, Enrollment::COMPLETED].include?(enrollment.status)
  end
end