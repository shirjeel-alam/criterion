ActiveAdmin.register Teacher do
  menu priority: 2, if: proc { current_admin_user.super_admin_or_partner? }

  filter :id
  filter :name
  filter :email
  filter :share

  index do
    column 'ID' do |teacher|
      link_to(teacher.id, admin_teacher_path(teacher))
    end
    column :name
    column :email
    column :share, sortable: :share do |teacher|
      number_to_percentage(teacher.share * 100, precision: 0)
    end if current_admin_user.super_admin_or_partner?
    column 'Contact Number' do |teacher|
      if teacher.phone_numbers.present?
        teacher.phone_numbers.each { |number| div number.label }
      else
        'No Phone Numbers Present'
      end
    end
    column 'Balance' do |teacher|
      status_tag(number_to_currency(teacher.teacher_balance, unit: 'Rs. ', precision: 0), teacher.balance_tag) rescue nil
    end

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name, required: true
      f.input :email, required: true
      f.input :share, required: true, step: 0.05

      f.has_many :phone_numbers do |fp|
        fp.input :number
        fp.input :category, as: :select, collection: PhoneNumber.categories, include_blank: false, input_html: { class: 'chosen-select' }
      end
    end

    f.buttons
  end

  show title: :name do
    panel 'Teacher Details' do
      attributes_table_for teacher do
        row(:id) { teacher.id }
        row(:name) { teacher.name }
        row(:email) { best_in_place_if(current_admin_user.super_admin_or_partner?, teacher, :email, as: :input, url: [:admin, teacher]) }
        row(:share) { number_to_percentage(teacher.share * 100, precision: 0) } if current_admin_user.super_admin_or_partner?
        row(:phone_numbers) do
          if teacher.phone_numbers.present?
            teacher.phone_numbers.each do |number|
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

        if current_admin_user.super_admin_or_partner? || current_admin_user.teacher?
          row(:balance) { status_tag(number_to_currency(teacher.teacher_balance, unit: 'Rs. ', precision: 0), teacher.balance_tag) rescue nil }
        end
        row(:active_enrollments) { teacher.enrollments.active.count }
      end
    end

    panel 'Payments (Income)' do
      temp_payments = teacher.payments.debit.where('courses.status IN (?)', [Course::NOT_STARTED, Course::IN_PROGRESS]).collect do |payment|
        payment.period = payment.period.beginning_of_month
        payment
      end
      result = temp_payments.group_by(&:period).sort_by(&:first)

      table do
        thead do
          tr do
            th 'ID'
            th 'Period'
            th 'Student'
            th 'Course'
            th 'Gross Amount'
            th 'Status'
            th 'Net Amount'
          end
        end

        tbody do
          flip = false
          result.each do |cumulative_payment|
            flip = !flip
            tr class: "#{flip ? 'odd' : 'even'} nested_header" do
              session_cumulative_amount = cumulative_payment.second.sum { |p| p.due? ? p.net_amount : 0 }

              td class: 'arrow down' do
                '&nbsp;'.html_safe
              end
              td cumulative_payment.first.strftime('%B %Y')
              td nil
              td nil
              td '-'
              td status_tag(session_cumulative_amount > 0 ? 'Due' : 'Paid', session_cumulative_amount > 0 ? :error : :ok)
              td status_tag(number_to_currency(session_cumulative_amount * teacher.share, unit: 'Rs. ', precision: 0), :warning)
            end

            cumulative_payment.second.group_by { |p| p.payable.course.name }.sort_by(&:first).each do |course_payment|
              flip = !flip
              tr class: "#{flip ? 'odd' : 'even'} header" do
                course_cumulative_amount = course_payment.second.sum { |p| p.due? ? p.net_amount : 0 }
                payment = course_payment.second.first

                td class: 'arrow down nested' do
                  '&nbsp;'.html_safe
                end
                td nil
                td nil
                td link_to(payment.payable.course.name, admin_course_path(payment.payable.course))
                td '-'
                td status_tag(course_cumulative_amount > 0 ? 'Due' : 'Paid', course_cumulative_amount > 0 ? :error : :ok)
                td status_tag(number_to_currency(course_cumulative_amount * teacher.share, unit: 'Rs. ', precision: 0), :warning)
              end

              flip = !flip
              course_payment.second.each do |payment|
                tr class: "#{flip ? 'odd' : 'even'} content" do
                  td link_to(payment.id, admin_payment_path(payment))
                  td nil
                  td link_to(payment.payable.student.name, admin_student_path(payment.payable.student))
                  td nil
                  td number_to_currency(payment.net_amount, unit: 'Rs. ', precision: 0)
                  td status_tag(payment.status_label, payment.status_tag)
                  td number_to_currency(payment.net_amount * teacher.share, unit: 'Rs. ', precision: 0)
                end
              end
            end
          end
        end
      end
    end if teacher.payments.debit.present?

    panel 'Payments (Deposits)' do
      paginated_collection(teacher.transactions.debit.order('payment_date').page(params[:page_debit]).per(25), param_name: :page_debit) do
        table_for collection do |t|
          t.column(:id) { |deposit| link_to(deposit.id, admin_payment_path(deposit)) }
          t.column(:payment_date) { |deposit| date_format(deposit.payment_date) }
          t.column(:narration) { |deposit| truncate(deposit.additional_info, length: 75) }
          t.column(:amount) { |deposit| number_to_currency(deposit.amount, unit: 'Rs. ', precision: 0) }
          t.column(:status) { |deposit| status_tag(deposit.status_label, deposit.status_tag) }
        end
      end
    end if teacher.transactions.debit.present?

    panel 'Payments (Withdrawal)' do
      paginated_collection(teacher.transactions.credit.order('payment_date').page(params[:page_credit]).per(25), param_name: :page_credit) do
        table_for collection do |t|
          t.column(:id) { |withdrawal| link_to(withdrawal.id, admin_payment_path(withdrawal)) }
          t.column(:payment_date) { |withdrawal| date_format(withdrawal.payment_date) }
          t.column(:narration) { |withdrawal| truncate(withdrawal.additional_info, length: 75) }
          t.column(:amount) { |withdrawal| number_to_currency(withdrawal.amount, unit: 'Rs. ', precision: 0) }
          t.column(:status) { |withdrawal| status_tag(withdrawal.status_label, withdrawal.status_tag) }
        end
      end
    end if teacher.transactions.credit.present?

    active_admin_comments
  end

  collection_action :find_teacher, method: :get do
    teacher = Teacher.find_by_id(params[:admin_user][:id])

    if teacher.present?
      redirect_to admin_teacher_path(teacher)
    else
      flash[:error] = 'Teacher Not Found'
      redirect_to_back
    end
  end

  action_item only: :show do
    span link_to('Add PhoneNumber', new_admin_phone_number_path(phone_number: { contactable_id: teacher.id, contactable_type: teacher.class.name }))
    span link_to('Debit Account (Withdrawal)', new_admin_payment_path(teacher_id: teacher, payment_type: Payment::CREDIT))
    span link_to('Credit Account (Deposit)', new_admin_payment_path(teacher_id: teacher, payment_type: Payment::DEBIT)) if current_admin_user.super_admin_or_partner?
  end

  controller do
    before_filter :check_authorization

    def check_authorization
      if current_admin_user.admin?
        if %w[index edit destroy].include?(action_name)
          flash[:error] = 'You are not authorized to perform this action'
          redirect_to_back
        end
      elsif current_admin_user.teacher?
        unless request.path == admin_teacher_path(current_admin_user.user) && action_name == 'show'
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
