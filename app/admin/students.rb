ActiveAdmin.register Student do
  filter :id
  filter :name
  
  index do
    column 'ID', :sortable => :id do |student|
      link_to(student.id, admin_student_path(student))
    end
    column :name
    column 'Address', :sortable => :address do |student|
      student.address_label
    end
    
    default_actions
  end
  
  show :title => :name do
    panel 'Student Details' do
      attributes_table_for student do
        row(:id) { student.id }
        row(:name) { student.name }
        row(:address) { student.address }
      end
    end
    
    panel 'Student Enrollments (In Progress)' do
      table_for student.enrollments.in_progress do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
        t.column(:session) { |enrollment| enrollment.course.session.label }
        t.column(:teacher) { |enrollment| link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
      end 
    end if student.enrollments.in_progress.present?
    
    panel 'Student Enrollments (Not Started)' do
      table_for student.enrollments.not_started do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
        t.column(:session) { |enrollment| enrollment.course.session.label }
        t.column(:teacher) { |enrollment| link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
      end 
    end if student.enrollments.not_started.present?
    
    panel 'Student Enrollments (Completed)' do
      table_for student.enrollments.completed do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
        t.column(:session) { |enrollment| enrollment.course.session.label }
        t.column(:teacher) { |enrollment| link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
      end      
    end if student.enrollments.completed.present?
    
    panel 'Student Enrollments (Cancelled)' do
      table_for student.enrollments.cancelled do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
        t.column(:session) { |enrollment| enrollment.course.session.label }
        t.column(:teacher) { |enrollment| link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
      end 
    end if student.enrollments.cancelled.present?
  end
    
  form do |f|
    f.inputs do
      f.input :name
      f.input :address
      
      f.has_many :phone_numbers do |fp|
        fp.inputs 'Contact Details' do
          fp.input :number
          fp.input :category, :as => :select, :collection => PhoneNumber.categories, :include_blank => false
        end
      end
      
      f.has_many :enrollments do |fe|
        fe.inputs 'Enrollment Details' do
          fe.input :course_id, :as => :select, :include_blank => false, :collection => Course.get_active
        end
      end
    end
    
    f.buttons
  end    
    
  action_item :only => :show do
    link_to('Add Enrollment', new_admin_enrollment_path(:student_id => student))
  end
end
