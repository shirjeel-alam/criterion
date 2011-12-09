ActiveAdmin.register Session do
  filter :period, :as => :select, :collection => Session.get_session_periods
  filter :year
  filter :registration_fee
  
  index do
    column 'ID', :sortable => :id do |session|
      link_to(session.id, admin_session_path(session))
    end
    column 'Period', :sortable => :period do |session|
      session.session_period_output
    end
    column 'Registration Fee', :sortable => :registration_fee do |session|
      number_to_currency(session.registration_fee, :unit => 'Rs. ', :precision => 0)
    end
    
    default_actions
  end
  
  show :title => :title do
    panel 'Session Details' do
      attributes_table_for session do
        row(:id) { session.id }
        row(:period) { session.session_period_output }
        row(:year) { session.year }
        row(:registration_fee) { number_to_currency(session.registration_fee, :unit => 'Rs. ', :precision => 0) }
      end
    end
    
    panel 'Courses' do
      table_for session.courses do |t|
        t.column(:id) { |course| link_to(course.id, admin_course_path(course)) }
        t.column(:name) { |course| link_to(course.name, admin_course_path(course)) }
        t.column(:teacher) { |course| link_to(course.teacher.name, admin_teacher_path(course.teacher)) }
        t.column(:enrollments) { |course| course.enrollments.count }
      end
    end
  end
end