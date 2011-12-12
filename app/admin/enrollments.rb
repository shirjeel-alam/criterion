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
      
    default_actions
  end
  
  form do |f|
    f.inputs do
      f.input :course_id, :as => :select, :include_blank => false, :collection => Course.get_all
      f.input :student_id, :as => :select, :include_blank => false, :collection => Student.get_all
      
      f.buttons
    end
  end
  
  show :title => :title do
    panel 'Enrollment Details' do
      attributes_table_for enrollment do
        row(:id) { enrollment.id }
        row(:student) { link_to(enrollment.student.name, admin_student_path(enrollment.student)) rescue nil }
        row(:course) { link_to(enrollment.course.name, admin_course_path(enrollment.course)) rescue nil }
      end
    end
    
    panel 'Payments' do
      table_for enrollment.payments do |t|
        t.column(:id) { |payment| link_to(payment.id, admin_payment_path(payment)) }
        t.column(:period) { |payment| payment.period_label}
        t.column(:amount) { |payment| number_to_currency(payment.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |payment| status_tag(payment.status_label, payment.status_tag) }
        t.column(:paid_on) { |payment| payment.date_label }
        t.column(:actions) { |payment| link_to('Make Payment', pay_admin_payment_path(payment), :method => :put) }
      end
    end
  end
end
