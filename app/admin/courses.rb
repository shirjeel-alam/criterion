ActiveAdmin.register Course do
  filter :name
  filter :status, :as => :select, :collection => Course.get_courses_status
  filter :monthly_fee
  
  index do
    column 'ID' do |course|
      link_to(course.id, admin_course_path(course))
    end
    column :name
    column :session do |course|
      session_output(course.session)
    end
    column :teacher do |course|
      course.teacher.present? ? course.teacher.name : 'N/A'
    end
    column :monthly_fee
    column :status, :sortable => :status do |course|
      status_tag(course_status_output(course), course_status_tag(course))
    end
    column :start_date, :sortable => :start_date do |course|
      course.start_date.present? ? course.start_date : 'N/A'
    end
    column :end_date
    
    default_actions
  end
end
