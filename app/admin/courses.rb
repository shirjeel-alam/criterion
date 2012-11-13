ActiveAdmin.register Course do
  menu priority: 2

  filter :id
  filter :name
  filter :level, as: :select, collection: Course.levels
  filter :teacher_name, as: :string

  scope :all, default: true do |courses|
    if current_admin_user.teacher?
      courses.where(teacher_id: current_admin_user.user.id)
    else
      courses
    end
  end

  scope :not_started do |courses|
    if current_admin_user.teacher?
      courses.not_started.where(teacher_id: current_admin_user.user.id)
    else
      courses.not_started
    end
  end

  scope :in_progress do |courses|
    if current_admin_user.teacher?
      courses.in_progress.where(teacher_id: current_admin_user.user.id)
    else
      courses.in_progress
    end
  end

  scope :completed do |courses|
    if current_admin_user.teacher?
      courses.completed.where(teacher_id: current_admin_user.user.id)
    else
      courses.completed
    end
  end

  scope :cancelled do |courses|
    if current_admin_user.teacher?
      courses.cancelled.where(teacher_id: current_admin_user.user.id)
    else
      courses.cancelled
    end
  end
  
  index do
    column 'ID' do |course|
      link_to(course.id, admin_course_path(course))
    end
    column :name
    column :level, sortable: :level do |course|
      course.level_label
    end
    column :session, sortable: :session_id do |course|
      course.session.label rescue nil
    end
    column :teacher, sortable: :teacher_id do |course|
      course.teacher.present? ? course.teacher.name : 'N/A'
    end
    column :monthly_fee, sortable: :monthly_fee do |course|
      number_to_currency(course.monthly_fee, unit: 'Rs. ', precision: 0)
    end
    column :status, sortable: :status do |course|
      status_tag(course.status_label, course.status_tag)
    end
    column :start_date, sortable: :start_date do |course|
      date_format(course.start_date)
    end
    column :end_date, sortable: :end_date do |course|
      date_format(course.end_date)
    end
    column :no_of_enrollments do |course|
      course.enrollments.active.count
    end
    
    default_actions
  end
  
  show title: :title do
    panel 'Course Details' do
      attributes_table_for course do
        row(:id) { course.id }
        row(:name) { course.name }
        row(:level) { course.level_label }
        row(:teacher) { link_to(course.teacher.name, admin_teacher_path(course.teacher)) }
        row(:session) { link_to(course.session.label, admin_session_path(course.session)) rescue nil }
        row(:monthly_fee) { course.monthly_fee }
        row(:no_of_enrollments) { course.enrollments.active.count }
        row(:status) { status_tag(course.status_label, course.status_tag) }
        row(:start_date) { date_format(course.start_date) }
        row(:end_date) { date_format(course.end_date) }
        row(:status_date) { date_format(course.course_date) }
        row(:time_table) do
          if course.schedules.present?
            course.schedules.order('id').each do |schedule|
              div do
                span schedule.label
                span link_to('Edit', edit_admin_schedule_path(schedule))
                span link_to('Delete', admin_schedule_path(schedule), method: :delete, data: { confirm: 'Are you sure?' })
              end
            end
          else
            'No Time Table Present'
          end
        end 
      end
    end
    
    panel 'Course Enrollments' do
      table_for course.enrollments do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:student) { |enrollment| link_to(enrollment.student.name, admin_student_path(enrollment.student)) }
        t.column(:phone_number) { |enrollment| enrollment.student.phone_numbers.first.number rescue nil }
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
        t.column(:registration_fee) { |enrollment| status_tag(enrollment.registration_fee.status_label, enrollment.registration_fee.status_tag) }
        t.column do |enrollment|
          registration_fee = enrollment.registration_fee
          if registration_fee.due?
            li link_to('Make Payment', pay_admin_payment_path(registration_fee), method: :get)
            li link_to('Void Payment', void_admin_payment_path(registration_fee), method: :put, data: { confirm: 'Are you sure?' })
          end
        end
      end
    end if course.enrollments.present?

    panel 'Course Fees Table' do
      months = months_between(course.start_date, course.end_date)
      table_for course.enrollments.order('start_date') do |t|
        t.column(:student) { |enrollment| link_to(enrollment.student.name, admin_student_path(enrollment.student)) }
        t.column(:join_date) { |enrollment| date_format(enrollment.start_date) }
        months.each do |month|
          t.column(date_format(month, true)) do |enrollment| 
            payment = enrollment.payment(month)
            payment.present? ? status_tag(payment.status_label, payment.status_tag) : '-'
          end
        end
      end
    end if course.enrollments.present? && course.started_or_completed?

    active_admin_comments
  end
  
  form do |f|
    f.inputs do
      f.input :name, required: true
      f.input :level, as: :radio, collection: Course.levels, required: true
      f.input :session, as: :select, collection: Session.get_active, include_blank: false, required: true, input_html: { class: 'chosen-select' }
      f.input :teacher, as: :select, collection: Teacher.get_all, include_blank: false, required: true, input_html: { class: 'chosen-select' }
      f.input :monthly_fee, required: true
      f.input :status, as: :select, collection: Course.statuses, include_blank: false, input_html: { class: 'chosen-select' }
      f.input :start_date, as: :datepicker, order: [:day, :month, :year]
      f.input :end_date, as: :datepicker, order: [:day, :month, :year], hint: 'Will be automatically set if left blank'
    end
    
    f.buttons
  end
  
  member_action :start, method: :put do
    course = Course.find(params[:id])
    if course.start!
      flash[:notice] = 'Course Started'
    else
      flash[:error] = 'Error Starting Course'
    end
    redirect_to action: :show
  end

  member_action :cancel, method: :put do
    course = Course.find(params[:id])
    if course.cancel!
      flash[:notice] = 'Course Cancelled'
    else
      flash[:error] = 'Error Cancelling Course'
    end
    redirect_to action: :show
  end
  
  member_action :finish, method: :put do
    course = Course.find(params[:id])
    if course.complete!
      flash[:notice] = 'Course Finished'
    else
      flash[:error] = 'Error Finishing Course'
    end
    redirect_to action: :show
  end

  collection_action :find_course, method: :get do
    course = Course.find_by_id(params[:admin_user][:id])

    if course.present?
      redirect_to admin_course_path(course)
    else
      flash[:error] = 'Course Not Found'
      redirect_to_back
    end
  end
  
  action_item only: :show do
    if current_admin_user.super_admin_or_partner? || current_admin_user.admin?
      span link_to('Add Enrollment', new_admin_enrollment_path(course_id: course)) unless (course.completed? || course.cancelled?)
      span link_to('Add Class Schedule', new_admin_schedule_path(schedule: { course_id: course }))
      span do
        if course.not_started?
          span link_to('Start Course', start_admin_course_path(course), method: :put, data: { confirm: 'Are you sure?' })
        elsif course.started?
          span link_to('Cancel Course', cancel_admin_course_path(course), method: :put, data: { confirm: 'Are you sure?' })
          span link_to('Finish Course', finish_admin_course_path(course), method: :put, data: { confirm: 'Are you sure?' })  
        end
      end
    end
  end

  controller do
    before_filter :check_authorization

    def check_authorization
      if current_admin_user.admin?
        if %w[edit destroy].include?(action_name)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      elsif current_admin_user.teacher?
        unless (action_name == 'index') || (action_name == 'show' && current_admin_user.user.courses.collect(&:id).include?(params[:id].to_i))
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      elsif current_admin_user.all_other?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end
  end
end