ActiveAdmin.register Book do
  menu priority: 2

  index do
    column 'ID', sortable: :id do |book|
      link_to(book.id, admin_book_path(book))
    end
    column :name
    column :course, sortable: :course_id do |book|
      book.course.name rescue nil
    end
    column :teacher do |book|
      book.course.teacher.name
    end
    column :share, sortable: :share do |book|
      number_to_percentage(book.share * 100, precision: 0)
    end if current_admin_user.super_admin_or_partner?
    column :amount, sortable: :amount do |book|
      number_to_currency(book.amount, unit: 'Rs. ', precision: 0)
    end

    default_actions
  end

  show title: :title do
    panel 'Book Details' do
      attributes_table_for book do
        row(:id) { book.id }
        row(:name) { book.name }
        row(:course) { link_to(book.course.name, admin_course_path(book.course)) rescue nil }
        row(:teacher) { link_to(book.course.teacher.name, admin_teacher_path(book.course.teacher)) rescue nil }
        row(:share) { number_to_percentage(book.share * 100, precision: 0) }
        row(:amount) { number_to_currency(book.amount, unit: 'Rs. ', precision: 0) }
      end
    end

    panel 'Payments' do
      table_for book.payments.order(:id) do |t|
        t.column(:id) { |payment| link_to(payment.id, admin_payment_path(payment)) }
        t.column(:student) { |payment| link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) }
        t.column(:gross_amount) { |payment| number_to_currency(best_in_place_if(current_admin_user.super_admin_or_partner? || (current_admin_user.admin? && payment.due?) , payment, :amount, as: :input, url: [:admin, payment]), unit: 'Rs. ', precision: 0) }
        t.column(:discount) { |payment| number_to_currency(best_in_place_if(current_admin_user.super_admin_or_partner? || (current_admin_user.admin? && payment.due?) , payment, :discount, as: :input, url: [:admin, payment]), unit: 'Rs. ', precision: 0) }
        t.column(:net_amount) { |payment| number_to_currency(payment.net_amount, unit: 'Rs. ', precision: 0) }
        t.column(:status) { |payment| status_tag(payment.status_label, payment.status_tag) }
        t.column(:actions) do |payment|
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

  form do |f|
    f.inputs do
      f.input :course, collection: Course.get_active, input_html: { class: 'chosen-select' }
      f.input :name
      f.input :amount
      f.input :share, required: false, step: 0.05, hint: 'If left empty will use books existing share value'
    end

    f.buttons
  end
end
