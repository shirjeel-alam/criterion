ActiveAdmin.register Enrollment do
  form do |f|
    f.inputs do
      f.input :course_id, :as => :select, :include_blank => false, :collection => Course.get_courses
      f.input :student_id, :as => :select, :include_blank => false, :collection => Student.get_students
      
      f.buttons
    end
  end  
end
