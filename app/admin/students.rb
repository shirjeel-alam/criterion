ActiveAdmin.register Student do
  filter :id
  filter :name
  
  index do
    column 'ID' do |student|
      link_to(student.id, admin_student_path(student))
    end
    column :name
    column :address
    
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
    
    panel 'Student Enrollments' do
      table_for student.enrollments do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
        t.column(:teacher) { |enrollment| link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
      end
    end
  end
    
  form do |f|
    f.inputs do
      f.input :name
      f.input :address
      
      f.has_many :phone_numbers do |fp|
        fp.inputs 'Contact Details' do
          fp.input :number
          fp.input :category, :as => :select, :collection => PhoneNumber.get_phone_number_categories, :include_blank => false
        end
      end
      
      f.has_many :enrollments do |fe|
        fe.inputs 'Enrollment Details' do
          fe.input :course_id, :as => :select, :include_blank => false, :collection => Course.get_courses
        end
      end
      
      f.buttons      
    end
  end    
  
  sidebar :actions, :only => :show do
    ul do
      li link_to('Add Enrollment', new_admin_enrollment_path(:enrollment => { :student_id => student }))
    end
  end
end
