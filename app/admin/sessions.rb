ActiveAdmin.register Session do
  menu parent: 'More Menus', if: proc { current_admin_user.super_admin_or_partner? }

  filter :id
  filter :year
  filter :registration_fee

  index do
    column 'ID', sortable: :id do |session|
      link_to(session.id, admin_session_path(session))
    end
    column 'Period', sortable: :period do |session|
      session.period_label
    end
    column :year
    column :status, sortable: :status do |session|
      status_tag(session.status_label, session.status_tag)
    end
    column 'Registration Fee', sortable: :registration_fee do |session|
      number_to_currency(session.registration_fee, unit: 'Rs. ', precision: 0) rescue nil
    end

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :period, as: :select, collection: Session.periods, include_blank: false, input_html: { class: 'chosen-select' }
      f.input :year, as: :select, collection: Session.years, include_blank: false, input_html: { class: 'chosen-select' }
      f.input :status, as: :select, collection: Session.statuses, include_blank: false, input_html: { class: 'chosen-select' }
      f.input :registration_fee
    end

    f.buttons
  end

  show title: :title do
    panel 'Session Details' do
      attributes_table_for session do
        row(:id) { session.id }
        row(:period) { session.period_label }
        row(:year) { session.year }
        row(:status) { status_tag(session.status_label, session.status_tag) }
        row(:registration_fee) { number_to_currency(session.registration_fee, unit: 'Rs. ', precision: 0) rescue nil }
        row(:courses) { session.courses.count.to_s }
      end
    end

    panel 'Courses' do
      table_for session.courses do |t|
        t.column(:id) { |course| link_to(course.id, admin_course_path(course)) }
        t.column(:name) { |course| link_to(course.name, admin_course_path(course)) }
        t.column(:teacher) { |course| link_to(course.teacher.name, admin_teacher_path(course.teacher)) }
        t.column(:enrollments) { |course| course.enrollments.active.count }
      end
    end

    active_admin_comments
  end

  action_item only: :show do
    link_to('Add Course', new_admin_course_path(course: { session_id: session }))
  end

  controller do
    before_filter :check_authorization

    def check_authorization
      unless current_admin_user.super_admin_or_partner?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end

    def new
      @session = Session.new(registration_fee: 500)
    end
  end
end
