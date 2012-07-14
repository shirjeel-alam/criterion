ActiveAdmin.register CriterionMonthlyReport do
  menu parent: 'Criterion', label: 'Profitability Reports', priority: 2, if: proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? }

  actions :index, :show

  filter :id
  filter :report_month

  index do
    column 'ID', sortable: :id do |report|
      link_to(report.id, admin_criterion_monthly_report_path(report))
    end
    column :report_month, sortable: :report_month do |report|
      date_format(report.report_month, true)
    end
    column :revenue, sortable: :revenue do |report|
      number_to_currency(report.revenue, unit: 'Rs. ', precision: 0)
    end
    column :expenditure, sortable: :expenditure do |report|
      number_to_currency(report.expenditure, unit: 'Rs. ', precision: 0)
    end
    column :balance, sortable: :balance do |report|
      status_tag(number_to_currency(report.balance, unit: 'Rs. ', precision: 0), report.balance_tag)
    end

    default_actions
  end

  show title: :title do
    panel 'Profitability Report Details' do
      attributes_table_for criterion_monthly_report do
        row(:id) { criterion_monthly_report.id }
        row(:report_month) { date_format(criterion_monthly_report.report_month, true) }
        row(:revenue) { number_to_currency(criterion_monthly_report.revenue, unit: 'Rs. ', precision: 0) }
        row(:expenditure) { number_to_currency(criterion_monthly_report.expenditure, unit: 'Rs. ', precision: 0) }
        row(:balance) { status_tag(number_to_currency(criterion_monthly_report.balance, unit: 'Rs. ', precision: 0), criterion_monthly_report.balance_tag) }
      end
    end

    panel 'Payments (Revenue)' do
      table_for criterion_monthly_report.payments(AccountEntry::CREDIT).order('payments.id') do |t|
        t.column(:id) { |payment| link_to(payment.id, admin_payment_path(payment)) }
        t.column(:paid_by) do |payment|
          if payment.payable.is_a?(Enrollment) || payment.payable.is_a?(SessionStudent)
            link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) rescue nil
          elsif payment.payable.is_a?(Teacher)
            link_to(payment.payable.name, admin_teacher_path(payment.payable)) rescue nil
          elsif payment.payable.is_a?(Partner)
            link_to(payment.payable.name, admin_partner_path(payment.payable)) rescue nil
          elsif payment.payable.is_a?(Staff)
            link_to(payment.payable.name, admin_staff_path(payment.payable)) rescue nil
          end
        end
        t.column(:category) { |payment| payment.category.name_label rescue nil }
        t.column(:payment_method) { |payment| status_tag(payment.payment_method_label, payment.payment_method_tag) }
        t.column(:net_amount) do |payment|
          if payment.payable.is_a?(Enrollment)
            amount = (payment.net_amount * (1 - payment.payable.teacher.share)).round
          elsif payment.payable.is_a?(SessionStudent)
            amount = payment.net_amount
          else
            amount = payment.net_amount
          end
          number_to_currency(amount, unit: 'Rs. ', precision: 0)
        end
      end
    end

    panel 'Payments (Expenditure)' do
      table_for criterion_monthly_report.payments(AccountEntry::DEBIT).order('payments.id') do |t|
        t.column(:id) { |payment| link_to(payment.id, admin_payment_path(payment)) }
        t.column(:paid_to) do |payment|
          if payment.payable.is_a?(Enrollment) || payment.payable.is_a?(SessionStudent)
            link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) rescue nil
          elsif payment.payable.is_a?(Teacher)
            link_to(payment.payable.name, admin_teacher_path(payment.payable)) rescue nil
          elsif payment.payable.is_a?(Partner)
            link_to(payment.payable.name, admin_partner_path(payment.payable)) rescue nil
          elsif payment.payable.is_a?(Staff)
            link_to(payment.payable.name, admin_staff_path(payment.payable)) rescue nil
          end
        end
        t.column(:category) { |payment| payment.category.name_label rescue nil }
        t.column(:payment_method) { |payment| status_tag(payment.payment_method_label, payment.payment_method_tag) }
        t.column(:amount) { |payment| number_to_currency(payment.amount, unit: 'Rs. ', precision: 0) }
      end
    end
  end
end
