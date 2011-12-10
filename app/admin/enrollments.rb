ActiveAdmin.register Enrollment do
  filter :id
  filter :course
  filter :student
  
  index do
    column 'ID' do |enrollment|
      link_to(enrollment.id, admin_enrollment_path(enrollment))
    end
    column 'Student' do |enrollment|
      link_to(enrollment.student.name, admin_student_path(enrollment.student))
    end
    column 'Course' do |enrollment|
      link_to(enrollment.course.name, admin_course_path(enrollment.course))
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
        row(:student) { link_to(enrollment.student.name, admin_student_path(enrollment.student)) }
        row(:course) { link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
      end
    end
    
    # panel 'Payments' do
    #   table_for enrollment.payments do |t|
    #     t.column(:id) { |payment| }
    #     t.column(:period) { |payment| }
    #     t.column(:amount) { |payment| }
    #     t.column(:status) { |payment| }
    #     t.column(:paid_on) { |payment| }
    #   end
    # end
  end
end
