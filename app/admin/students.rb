ActiveAdmin.register Student do
  menu :if => proc { current_admin_user.super_admin? || current_admin_user.admin? }

  filter :id
  filter :name
  
  index do
    column 'ID', :sortable => :id do |student|
      link_to(student.id, admin_student_path(student))
    end
    column :name
    column :email
    column 'Address', :sortable => :address do |student|
      student.address_label
    end
    column 'Contact Number' do |student|
      student.phone_numbers.each { |number| div number.label }
    end
    
    default_actions
  end
  
  show :title => :name do
    panel 'Student Details' do
      attributes_table_for student do
        row(:id) { student.id }
        row(:name) { student.name }
        row(:email) { student.email }
        row(:address) { student.address }
      end
    end

    panel 'Payment (Registration Fees)' do
      table_for student.student_registration_fees.each do |t|
        t.column(:id) { |registration_fee| link_to(registration_fee.id, admin_student_registration_fee_path(registration_fee)) }
        t.column(:session) { |registration_fee| registration_fee.session.label rescue nil }
        t.column(:amount) { |registration_fee| number_to_currency(registration_fee.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |registration_fee| status_tag(registration_fee.status_label, registration_fee.status_tag) }
        t.column { |registration_fee| link_to('Make Payment', pay_admin_student_registration_fee_path(registration_fee), :method => :put) unless registration_fee.status }
      end
    end
    
    panel 'Payments' do
      temp_payments = student.payments.collect do |payment|
        payment.period = payment.period.beginning_of_month
        payment
      end
      result = temp_payments.group_by(&:period)
      
      table do
        thead do
          tr do
            th 'ID'
            th 'Period'
            th 'Course'
            th 'Gross Amount'
            th 'Discount'
            th 'Net Amount'
            th 'Status'
            th nil
          end
        end
        
        tbody do
          flip = true
          result.each do |cumulative_payment|
            tr :class => "#{flip ? 'odd' : 'even'} header" do
              cumulative_gross_amount = cumulative_payment.second.sum { |p| p.paid? || p.void? ? 0 : p.amount }
              cumulative_discount = cumulative_payment.second.sum { |p| p.paid? || p.void? ? 0 : (p.discount.present? ? p.discount : 0) }
              cumulative_net_amount = cumulative_gross_amount - cumulative_discount

              td image_tag('down_arrow.png')
              td cumulative_payment.first.strftime('%B %Y')
              td nil
              td number_to_currency(cumulative_gross_amount, :unit => 'Rs. ', :precision => 0)
              td number_to_currency(cumulative_discount, :unit => 'Rs. ', :precision => 0)
              td number_to_currency(cumulative_net_amount, :unit => 'Rs. ', :precision => 0)
              td status_tag(cumulative_net_amount > 0 ? 'Due' : 'Paid', cumulative_net_amount > 0 ? :error : :ok)
              td cumulative_net_amount > 0 ? link_to('Make Payment (Cumulative)', pay_cumulative_admin_payments_path(:payments => cumulative_payment.second), :method => :put) : nil
            end
            
            flip = !flip
            cumulative_payment.second.each do |payment|
              tr :class => "#{flip ? 'odd' : 'even'} content" do
                td link_to(payment.id, admin_payment_path(payment))
                td payment.period_label
                td link_to(payment.payable.course.name, admin_course_path(payment.payable.course))
                td number_to_currency(best_in_place_if(current_admin_user.super_admin? && payment.due?, payment, :amount, :type => :input, :path => [:admin, payment]), :unit => 'Rs. ', :precision => 0)
                td number_to_currency(best_in_place_if(current_admin_user.super_admin? && payment.due?, payment, :discount, :type => :input, :path => [:admin, payment]), :unit => 'Rs. ', :precision => 0)
                td number_to_currency(payment.net_amount, :unit => 'Rs. ', :precision => 0)
                td status_tag(payment.status_label, payment.status_tag)
                td do
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
          end
        end
      end
    end
    
    panel 'Student Enrollments (In Progress)' do
      table_for student.enrollments.in_progress do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
        t.column(:session) { |enrollment| link_to(enrollment.course.session.label, admin_session_path(enrollment.course.session)) rescue nil }
        t.column(:teacher) { |enrollment| link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
      end 
    end if student.enrollments.in_progress.present?
    
    panel 'Student Enrollments (Not Started)' do
      table_for student.enrollments.not_started do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
        t.column(:session) { |enrollment| link_to(enrollment.course.session.label, admin_session_path(enrollment.course.session)) rescue nil }
        t.column(:teacher) { |enrollment| link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
      end 
    end if student.enrollments.not_started.present?
    
    panel 'Student Enrollments (Completed)' do
      table_for student.enrollments.completed do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
        t.column(:session) { |enrollment| link_to(enrollment.course.session.label, admin_session_path(enrollment.course.session)) rescue nil }
        t.column(:teacher) { |enrollment| link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
      end      
    end if student.enrollments.completed.present?
    
    panel 'Student Enrollments (Cancelled)' do
      table_for student.enrollments.cancelled do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
        t.column(:session) { |enrollment| link_to(enrollment.course.session.label, admin_session_path(enrollment.course.session)) rescue nil }
        t.column(:teacher) { |enrollment| link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
      end 
    end if student.enrollments.cancelled.present?
  end
    
  form do |f|
    f.inputs do
      f.input :name, :required => true
      f.input :email
      f.input :address
      
      f.has_many :phone_numbers do |fp|
        fp.inputs 'Contact Details' do
          fp.input :number
          fp.input :category, :as => :select, :collection => PhoneNumber.categories, :include_blank => false, :input_html => { :class => 'chosen-select' }
        end
      end
      
      f.has_many :enrollments do |fe|
        fe.inputs 'Enrollment Details' do
          
        end
        fe.input :course_id, :as => :select, :include_blank => false, :collection => Course.get_active, :input_html => { :class => 'chosen-select' }
        fe.input :start_date, :as => :datepicker, :label => 'Start Date', :input_html => { :class => 'date_input' }
      end
    end
    
    f.buttons
  end    
    
  action_item :only => :show do
    link_to('Add Enrollment', new_admin_enrollment_path(:student_id => student))
  end

  controller do
    before_filter :check_authorization

    def check_authorization
      if current_admin_user.admin?
        if %w[edit destroy].include?(action_name)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to :back
        end
      end
    end
  end
end
