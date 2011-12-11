ActiveAdmin.register Course do
  filter :id
  filter :name
  filter :status, :as => :select, :collection => Course.statuses
  filter :monthly_fee
  
  index do
    column 'ID' do |course|
      link_to(course.id, admin_course_path(course))
    end
    column :name
    column :session do |course|
      course.session.label
    end
    column :teacher do |course|
      course.teacher.present? ? course.teacher.name : 'N/A'
    end
    column :monthly_fee, :sortable => :monthly_fee do |course|
      number_to_currency(course.monthly_fee, :unit => 'Rs. ', :precision => 0)
    end
    column :status, :sortable => :status do |course|
      status_tag(course.status_label, course.status_tag)
    end
    column :start_date, :sortable => :start_date do |course|
      date_format(course.start_date)
    end
    column :end_date, :sortable => :end_date do |course|
      date_format(course.end_date)
    end
    
    default_actions
  end
  
  show :title => :title do
    panel 'Course Details' do
      attributes_table_for course do
        row(:id) { course.id }
        row(:name) { course.name }
        row(:teacher) { course.teacher.name }
        row(:session) { course.session.label }
        row(:monthly_fee) { course.monthly_fee }
        row(:no_of_enrollments) { course.enrollments.count }
        row(:status) { status_tag(course.status_label, course.status_tag) }
        row(:start_date) { date_format(course.start_date) }
        row(:end_date) { date_format(course.end_date) }
      end
    end
    
    panel 'Course Enrollments' do
      table_for course.enrollments do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:student) { |enrollment| link_to(enrollment.student.name, admin_student_path(enrollment.student)) }
        t.column(:phone_number) { |enrollment| enrollment.student.phone_numbers.first.number rescue nil }
      end
    end
  end
  
  form do |f|
    f.inputs do
      f.input :name, :required => true
      f.input :session, :as => :select, :collection => Session.get_active, :include_blank => false, :required => true
      f.input :teacher, :as => :select, :collection => Teacher.get_all, :include_blank => false, :required => true
      f.input :monthly_fee, :required => true
      f.input :status, :as => :select, :collection => Course.statuses, :include_blank => false
      f.input :start_date, :as => :date, :order => [:day, :month, :year]
      f.input :end_date, :as => :date, :order => [:day, :month, :year], :hint => 'Will be automatically set if left blank'
      
      f.buttons
    end
  end
  
  sidebar :actions, :only => :show do
    ul do
      li link_to('Start Course', start_admin_course_path(course), :method => :put) unless course.started?
      li link_to('Reset Course', reset_admin_course_path(course), :method => :put) if course.started?
    end
  end
  
  member_action :start, :method => :put do
    course = Course.find(params[:id])
    course.update_attributes(:start_date => Date.today)
    flash[:notice] = 'Course Started'
    redirect_to :action => :show
  end
  
  member_action :reset, :method => :put do
    course = Course.find(params[:id])
    course.update_attributes(:start_date => nil)
    flash[:notice] = 'Course Reset'
    redirect_to :action => :show
  end
end
