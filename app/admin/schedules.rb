ActiveAdmin.register Schedule do
  menu parent: 'More Menus', if: proc { current_admin_user.super_admin_or_partner? }

  index do
    column 'ID', sortable: :id do |schedule|
      link_to(schedule.id, admin_schedule_path(schedule))
    end
    column :course, sortable: :course_id do |schedule|
      link_to(schedule.course.name, admin_course_path(schedule.course))
    end
    column :day
    column 'Time' do |schedule|
      "#{time_format(schedule.start)} - #{time_format(schedule.end)}"
    end
    column :room

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :course_id, as: :select, required: true, collection: Course.active, input_html: { class: 'chosen-select', style: 'width:77.8%;' }
      f.input :start, as: :time, ampm: true, input_html: { class: 'chosen-select', style: 'width:300px;' }
      f.input :end, as: :time, ampm: true, input_html: { class: 'chosen-select', style: 'width:300px;' }
      f.input :day, as: :select, collection: days, required: true, input_html: { class: 'chosen-select' }
      f.input :room, as: :select, collection: rooms, required: true, input_html: { class: 'chosen-select' }
    end

    f.buttons
  end

  show title: :title do
    panel 'Schedule Details' do
      attributes_table_for schedule do
        row(:id) { schedule.id }
        row(:course) { link_to(schedule.course.name, admin_course_path(schedule.course)) }
        row(:day) { schedule.day }
        row(:start) { time_format schedule.start }
        row(:end) { time_format schedule.end }
        row(:room)
      end
    end
  end

  controller do
    def create
      @schedule = Schedule.new(params[:schedule])
      @schedule.start = make_time(params[:schedule]['start(4i)'], params[:schedule]['start(5i)'])
      @schedule.end = make_time(params[:schedule]['end(4i)'], params[:schedule]['end(5i)'])
      create!
    end

    def update
      @schedule = Schedule.find(params[:id])
      @schedule.attributes = params[:schedule]
      @schedule.start = make_time(params[:schedule]['start(4i)'], params[:schedule]['start(5i)'])
      @schedule.end = make_time(params[:schedule]['end(4i)'], params[:schedule]['end(5i)'])
      update!
    end

    def make_time(hour, minute)
      Time.parse("#{hour}:#{minute}").to_time
    end
  end
end