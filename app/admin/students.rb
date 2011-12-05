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
end
