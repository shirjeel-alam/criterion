ActiveAdmin.register Enrollment do
  filter :id
  filter :course
  filter :student
  
  index do
    column 'ID' do |enrollment|
      link_to(enrollment.id, admin_enrollment_path(enrollment))
    end
    column 'Student' do |enrollment|
      link_to(enrollment.student.name, admin_student_path(enrollment.student)) rescue nil
    end
    column 'Course' do |enrollment|
      link_to(enrollment.course.name, admin_course_path(enrollment.course)) rescue nil
    end
    column 'Status' do |enrollment|
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
        row(:status) { status_tag(enrollment.status_label, enrollment.status_tag) }
      end
    end
    
    panel 'Payments' do
      table_for enrollment.payments.order(:id) do |t|
        t.column(:id) { |payment| link_to(payment.id, admin_payment_path(payment)) }
        t.column(:period) { |payment| payment.period_label}
        t.column(:gross_amount) { |payment| number_to_currency(payment.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:discount) { |payment| number_to_currency(payment.discount, :unit => 'Rs. ', :precision => 0) }
        t.column(:net_amount) { |payment| number_to_currency(payment.net_amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |payment| status_tag(payment.status_label, payment.status_tag) }
        t.column(:paid_on) { |payment| payment.date_label }
        t.column(:actions) { |payment| link_to('Make Payment', pay_admin_payment_path(payment), :method => :put) unless payment.status }
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
      flash[:error] = 'Enrollment Cancelled'
    else
      flash[:error] = 'Error Cancelling Enrollment'
    end
    redirect_to :action => :show
  end

  member_action :refresh, :method => :put do
    enrollment = Enrollment.find(params[:id])
    enrollment.create_payments
    redirect_to :action => :show
  end
  
  action_item :only => :show do
    span link_to('Refresh Enrollment', refresh_admin_enrollment_path(enrollment), :method => :put)
    span link_to('Cancel Enrollment', cancel_admin_enrollment_path(enrollment), :method => :put, :confirm => 'Are you sure?') unless [Enrollment::CANCELLED, Enrollment::COMPLETED].include?(enrollment.status)
  end

  action_item :only => :index do
    link_to('New Enrollment', new_admin_enrollment_path)
  end
end
