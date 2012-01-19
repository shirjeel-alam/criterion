ActiveAdmin.register Session do
  menu :if => proc { current_admin_user.super_admin? }

  filter :period, :as => :select, :collection => lambda { Session.get_all }
  filter :year
  filter :status, :as => :select, :collection => lambda { Session.statuses }
  filter :registration_fee
  
  index do
    column 'ID', :sortable => :id do |session|
      link_to(session.id, admin_session_path(session))
    end
    column 'Period', :sortable => :period do |session|
      session.period_label
    end
    column :year
    column :status, :sortable => :status do |session|
      status_tag(session.status_label, session.status_tag)
    end
    column 'Registration Fee', :sortable => :registration_fee do |session|
      number_to_currency(session.registration_fee, :unit => 'Rs. ', :precision => 0)
    end
    
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :period, :as => :select, :collection => Session.periods, :include_blank => false
      f.input :year, :as => :select, :collection => Session.years, :include_blank => false
      f.input :status, :as => :select, :collection => Session.statuses, :include_blank => false
      f.input :registration_fee
    end

    f.buttons
  end
  
  show :title => :title do
    panel 'Session Details' do
      attributes_table_for session do
        row(:id) { session.id }
        row(:period) { session.period_label }
        row(:year) { session.year }
        row(:status) { status_tag(session.status_label, session.status_tag) }
        row(:registration_fee) { number_to_currency(session.registration_fee, :unit => 'Rs. ', :precision => 0) }
        row(:courses) { session.courses.count.to_s }
      end
    end
    
    panel 'Courses' do
      table_for session.courses do |t|
        t.column(:id) { |course| link_to(course.id, admin_course_path(course)) }
        t.column(:name) { |course| link_to(course.name, admin_course_path(course)) }
        t.column(:teacher) { |course| link_to(course.teacher.name, admin_teacher_path(course.teacher)) }
        t.column(:enrollments) { |course| course.enrollments.count.to_s }
      end
    end

    panel 'Payment (Registration Fees)' do
      table_for session.student_registration_fees.each do |t|
        t.column(:id) { |registration_fee| registration_fee.id.to_s }
        t.column(:student) { |registration_fee| link_to(registration_fee.student.name, admin_student_path(registration_fee.student)) }
        t.column(:amount) { |registration_fee| number_to_currency(registration_fee.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:status) { |registration_fee| status_tag(registration_fee.status_label, registration_fee.status_tag) }
        t.column { |registration_fee| link_to('Make Payment', pay_admin_student_registration_fee_path(registration_fee), :method => :put) unless registration_fee.status }
      end
    end
  end

  action_item :only => :show do
    link_to('Add Course', new_admin_course_path(:course => { :session_id => session }))
  end
end
