ActiveAdmin.register Course do
  filter :id
  filter :name
  filter :status, :as => :select, :collection => lambda { Course.statuses }
  filter :monthly_fee
  
  index do
    column 'ID' do |course|
      link_to(course.id, admin_course_path(course))
    end
    column :name
    column :session do |course|
      course.session.label rescue nil
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
        row(:session) { course.session.label rescue nil }
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
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
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
      f.input :start_date, :as => :datepicker, :order => [:day, :month, :year]
      f.input :end_date, :as => :datepicker, :order => [:day, :month, :year], :hint => 'Will be automatically set if left blank'
    end
    
    f.buttons
  end
  
  member_action :start, :method => :put do
    course = Course.find(params[:id])
    course.attributes = { :start_date => Date.today }
    if course.save
      course.enrollments_update_status
      flash[:notice] = 'Course Started'
    else
      flash[:error] = 'Error Starting Course'
    end
    redirect_to :action => :show
  end
  
  member_action :reset, :method => :put do
    course = Course.find(params[:id])
    course.attributes = { :start_date => nil, :end_date => nil }
    if course.save
      course.enrollments_update_status
      flash[:notice] = 'Course Reset'
    else
      flash[:error] = 'Error Restarting Course'
    end
    redirect_to :action => :show
  end
  
  member_action :finish, :method => :put do
    course = Course.find(params[:id])
    course.attributes = { :status => Course::COMPLETED, :end_date => Date.today, :course_date => Date.today, :course_date_for => Course::COMPLETION }
    if course.save
      course.enrollments_update_status
      flash[:notice] = 'Course Finished'
    else
      flash[:error] = 'Error Finishing Course'
    end
    redirect_to :action => :show
  end
  
  #NOTE: Reset Course only for development purposes
  action_item :only => :show do
    span link_to('Add Enrollment', new_admin_enrollment_path(:course_id => course))
    span do
      if course.started?
        span link_to('Reset Course', reset_admin_course_path(course), :method => :put, :confirm => 'Are you sure?')
        span link_to('Finish Course', finish_admin_course_path(course), :method => :put, :confirm => 'Are you sure?')
      else
        span link_to('Reset Course', reset_admin_course_path(course), :method => :put, :confirm => 'Are you sure?')
        span link_to('Start Course', start_admin_course_path(course), :method => :put, :confirm => 'Are you sure?')
      end
    end
  end
end
