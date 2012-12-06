ActiveAdmin.register_page 'Time Table' do
  menu false # , priority: 2

  content do
    table class: 'index_table' do
      thead do
        tr do
          th 'Course'
          th 'Classes'
          th nil
        end
      end

      tbody do
        courses.each do |course|
          tr do
            td link_to(course.name, admin_course_path(course))
            if course.schedules.present?
              td do
                course.schedules.order('id').each { |schedule| div schedule.label }
              end
              td do
                course.schedules.order('id').each do |schedule|
                  div do
                    span link_to('View', admin_schedule_path(schedule))
                    span link_to('Edit', edit_admin_schedule_path(schedule))
                    span link_to('Delete', admin_schedule_path(schedule), method: :delete, data: { confirm: 'Are you sure?' })
                  end
                end
              end
            else
              td 'No Time Table Present'
              td nil 
            end  
          end
        end
      end
    end
  end

  sidebar :filter do
    p 'Filtering Options'
  end

  controller do
    def index
      @courses = Course.active.with_schedule.uniq
    end
  end
end