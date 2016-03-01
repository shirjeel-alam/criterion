ActiveAdmin.register Student do
  menu priority: 2, if: proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? }

  filter :id
  filter :name
  filter :email
  filter :phone_numbers_number, as: :string, label: 'Phone Number'

  index do
    column 'ID', sortable: :id do |student|
      link_to(student.id, admin_student_path(student))
    end
    column :name
    column 'Active Enrollment(s)' do |student|
      ul do
        student.enrollments.active.each { |enrollment| li enrollment.course.title }
      end if student.enrollments.active.present?
    end
    column 'Contact Number' do |student|
      student.phone_numbers.each { |number| div number.label } if student.phone_numbers.present?
    end

    default_actions
  end

  show title: :name do
    panel 'Student Details' do
      attributes_table_for student do
        row(:id) { student.id }
        row(:name) { best_in_place_if((current_admin_user.super_admin_or_partner? || current_admin_user.admin?), student, :name, as: :input, url: [:admin, student]) }
        row(:email) { best_in_place_if((current_admin_user.super_admin_or_partner? || current_admin_user.admin?), student, :email, as: :input, url: [:admin, student]) }
        row(:address) { best_in_place_if((current_admin_user.super_admin_or_partner? || current_admin_user.admin?), student, :address, as: :input, url: [:admin, student]) }
        row(:phone_numbers) do
          if student.phone_numbers.present?
            student.phone_numbers.each do |number|
              div do
                span number.label
                span link_to('Edit', edit_admin_phone_number_path(number))
                span link_to('Delete', admin_phone_number_path(number), method: :delete, data: { confirm: 'Are you sure?' })
              end
            end
          else
            'No Phone Numbers Present'
          end
        end
      end
    end

    panel 'Payment (Registration Fees)' do
      table_for student.session_students.select(&:registration_fee?).each do |t|
        t.column(:id) { |session_student| link_to(session_student.registration_fee.id, admin_payment_path(session_student.registration_fee)) }
        t.column(:session) { |session_student| link_to(session_student.session.label, admin_session_path(session_student.session)) }
        t.column(:amount) { |session_student| number_to_currency(session_student.registration_fee.amount, unit: 'Rs. ', precision: 0) }
        t.column(:status) { |session_student| status_tag(session_student.registration_fee.status_label, session_student.registration_fee.status_tag) }
        t.column do |session_student|
          if session_student.registration_fee? && session_student.registration_fee.due?
            li link_to('Make Payment', pay_admin_payment_path(session_student.registration_fee), method: :get)
            li link_to('Void Payment', void_admin_payment_path(session_student.registration_fee), method: :put, data: { confirm: 'Are you sure?' })
          elsif session_student.registration_fee.present? && session_student.registration_fee.void?
            li link_to('Make Payment Due', due_admin_payment_path(session_student.registration_fee), method: :put, data: { confirm: 'Are you sure?' })
          end
        end
      end
    end

    panel 'Payments' do
      temp_payments = student.payments.collect do |payment|
        payment.period = payment.period.beginning_of_month
        payment
      end
      result = temp_payments.group_by(&:period).sort_by(&:first)

      table do
        thead do
          tr do
            th 'ID'
            th 'Period'
            th 'Course'
            th 'Gross Amount'
            th 'Discount'
            th 'Net Amount'
            th 'Status'
            th nil
          end
        end

        tbody do
          flip = true
          result.each do |cumulative_payment|
            tr class: "#{flip ? 'odd' : 'even'} header" do
              cumulative_payment_due = cumulative_payment.second.select(&:due?)
              cumulative_gross_amount = cumulative_payment_due.sum(&:amount)
              cumulative_discount = cumulative_payment_due.map(&:discount).compact.sum
              cumulative_net_amount = cumulative_gross_amount - cumulative_discount

              td class: 'arrow down' do
                '&nbsp;'.html_safe
              end
              td cumulative_payment.first.strftime('%B %Y')
              td nil
              td number_to_currency(cumulative_gross_amount, unit: 'Rs. ', precision: 0)
              td number_to_currency(cumulative_discount, unit: 'Rs. ', precision: 0)
              td number_to_currency(cumulative_net_amount, unit: 'Rs. ', precision: 0)
              td status_tag(cumulative_net_amount > 0 ? 'Due' : 'Paid', cumulative_net_amount > 0 ? :error : :ok)
              td cumulative_net_amount > 0 ? link_to('Make Payment (Cumulative)', pay_cumulative_admin_payments_path(payments: cumulative_payment_due)) : nil
            end

            flip = !flip
            cumulative_payment.second.sort_by(&:id).each do |payment|
              tr class: "#{flip ? 'odd' : 'even'} content" do
                td link_to(payment.id, admin_payment_path(payment))
                td nil
                td link_to(payment.payable.course.name, admin_course_path(payment.payable.course))
                td number_to_currency(best_in_place_if(current_admin_user.super_admin_or_partner? || (current_admin_user.admin? && payment.due?) , payment, :amount, as: :input, url: [:admin, payment]), unit: 'Rs. ', precision: 0)
                td number_to_currency(best_in_place_if(current_admin_user.super_admin_or_partner? || (current_admin_user.admin? && payment.due?) , payment, :discount, as: :input, url: [:admin, payment]), unit: 'Rs. ', precision: 0)
                td number_to_currency(payment.net_amount, unit: 'Rs. ', precision: 0)
                td status_tag(payment.status_label, payment.status_tag)
                td do
                  ul do
                    if payment.due?
                      li span link_to('Make Payment', pay_admin_payment_path(payment))
                      li span link_to('Void Payment', void_admin_payment_path(payment), method: :put, data: { confirm: 'Are you sure?' })
                    elsif payment.paid?
                      li span link_to('Refund Payment', refund_admin_payment_path(payment), method: :put, data: { confirm: 'Are you sure?' })
                    elsif payment.refunded?
                      li span link_to('Make Payment', pay_admin_payment_path(payment))
                    elsif payment.void?
                      li link_to('Make Payment Due', due_admin_payment_path(payment), method: :put, data: { confirm: 'Are you sure?' })
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    panel 'Student Enrollments' do
      table_for student.enrollments do |t|
        t.column(:id) { |enrollment| link_to(enrollment.id, admin_enrollment_path(enrollment)) }
        t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
        t.column(:session) { |enrollment| link_to(enrollment.course.session.label, admin_session_path(enrollment.course.session)) rescue nil }
        t.column(:teacher) { |enrollment| link_to(enrollment.course.teacher.name, admin_teacher_path(enrollment.course.teacher)) }
        t.column(:status) { |enrollment| status_tag(enrollment.status_label, enrollment.status_tag) }
      end
    end if student.enrollments.present?

    panel 'Student Fees Table' do
      sessions = student.enrollments.started_or_completed.sort_by(&:session_id).group_by(&:session_id)

      sessions.each do |session|
        panel "#{Session.find(session.first).title}" do
          start_date = session.second.collect(&:start_date).min
          end_date = session.second.collect(&:end_date).max
          months = months_between(start_date, end_date)
          table_for session.second do |t|
            t.column(:course) { |enrollment| link_to(enrollment.course.name, admin_course_path(enrollment.course)) }
            t.column(:join_date) { |enrollment| date_format(enrollment.start_date) }
            months.each do |month|
              t.column(date_format(month, true)) do |enrollment|
                payment = enrollment.payment(month)
                payment.present? ? status_tag(payment.status_label, payment.status_tag) : '-'
              end
            end
          end
        end
      end
    end if student.courses.present?

    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :name, required: true
      f.input :email
      f.input :address

      f.has_many :phone_numbers do |fp|
        fp.input :number
        fp.input :belongs_to, as: :radio, collection: PhoneNumber.belongs_to, required: true
        fp.input :category, as: :radio, collection: PhoneNumber.categories, required: true
      end

      f.has_many :enrollments do |fe|
        fe.input :course_id, as: :select, include_blank: false, collection: Course.get_active, input_html: { class: 'chosen-select' }
        fe.input :start_date, as: :datepicker, label: 'Start Date', input_html: { class: 'date_input' }
      end
    end

    f.buttons
  end

  csv do
    column :id
    column :name
    column :email
    column :address
    column 'Contact Number' do |student|
      student.phone_numbers.collect { |number| number.label } if student.phone_numbers.present?
    end
  end

  action_item only: :show do
    span link_to('Add Enrollment', new_admin_enrollment_path(student_id: student))
    span link_to('Add PhoneNumber', new_admin_phone_number_path(phone_number: { contactable_id: student.id, contactable_type: student.class.name }))
  end

  collection_action :find_student, method: :get do
    student = Student.find_by_id(params[:admin_user][:id])

    if student.present?
      redirect_to admin_student_path(student)
    else
      flash[:error] = 'Student Not Found'
      redirect_to_back
    end
  end

  member_action :new_fee_receipt, method: :get do
    @student = resource
    @session_students = @student.session_students.joins(:registration_fee).where('payments.status = ?', Payment::DUE)
    @payments = @student.payments.due.collect do |payment|
        payment.period = payment.period.beginning_of_month
        payment
      end
    @payments = @payments.group_by(&:period).sort_by(&:first)
  end

  controller do
    before_filter :check_authorization

    def check_authorization
      if current_admin_user.admin?
        if %w[edit destroy].include?(action_name)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      elsif current_admin_user.all_other?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end

    def create
      @student = Student.new(params[:student])
      unless @student.valid?
        flash[:error] = @student.errors[:base].first
      end
      create!
    end
  end
end
