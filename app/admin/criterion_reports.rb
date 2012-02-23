ActiveAdmin.register CriterionReport do
	menu :parent => 'Criterion', :priority => 2, :if => proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? }
	
	actions :index, :show

	filter :id
	filter :report_date
	
	index do
		column 'ID', :sortable => :id do |report|
			link_to(report.id, admin_criterion_report_path(report))
		end
		column :report_date, :sortable => :report_date do |report|
			date_format(report.report_date)
		end
		column :gross_revenue, :sortable => :gross_revenue do |report|
			number_to_currency(report.gross_revenue, :unit => 'Rs. ', :precision => 0)
		end
		column :discounts, :sortable => :discounts do |report|
			number_to_currency(report.discounts, :unit => 'Rs. ', :precision => 0)
		end
		column :net_revenue, :sortable => :net_revenue do |report|
			number_to_currency(report.net_revenue, :unit => 'Rs. ', :precision => 0)
		end
		column :expenditure, :sortable => :expenditure do |report|
			number_to_currency(report.expenditure, :unit => 'Rs. ', :precision => 0)
		end
		column :balance, :sortable => :balance do |report|
			status_tag(number_to_currency(report.balance, :unit => 'Rs. ', :precision => 0), report.balance_tag)
		end
		column :last_updated do |report|
			time_format(report.updated_at)
		end
		column nil do |report|
			span link_to('View', admin_criterion_report_path(report), :class => :member_link)
			span link_to('Update', update_report_admin_criterion_report_path(report), :method => :put, :class => :member_link)
		end
	end

	show :title => :title do
		panel 'Criterion Report Details' do
			attributes_table_for criterion_report do
				row(:id) { criterion_report.id }
				row(:report_date) { date_format(criterion_report.report_date) }
				row(:gross_revenue) { number_to_currency(criterion_report.gross_revenue, :unit => 'Rs. ', :precision => 0) }
				row(:discounts) { number_to_currency(criterion_report.discounts, :unit => 'Rs. ', :precision => 0) }
				row(:net_revenue) { number_to_currency(criterion_report.net_revenue, :unit => 'Rs. ', :precision => 0) }
				row(:expenditure) { number_to_currency(criterion_report.expenditure, :unit => 'Rs. ', :precision => 0) }
				row(:balance) { status_tag(number_to_currency(criterion_report.balance, :unit => 'Rs. ', :precision => 0), criterion_report.balance_tag) }
			end
		end

		panel 'Payments (Revenue)' do
			table_for Payment.debit.paid.cash_or_cheque.on(criterion_report.report_date).order(:id) do |t|
        t.column(:id) { |payment| link_to(payment.id, admin_payment_path(payment)) }
        t.column(:period) { |payment| payment.period_label}
        t.column(:gross_amount) { |payment| number_to_currency(payment.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:discount) { |payment| number_to_currency(payment.discount, :unit => 'Rs. ', :precision => 0) }
        t.column(:net_amount) { |payment| number_to_currency(payment.net_amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:paid_by) do |payment|
        	if payment.payable.is_a?(Enrollment)
						link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) rescue nil
					elsif payment.payable.is_a?(Teacher)
						link_to(payment.payable.name, admin_teacher_path(payment.payable)) rescue nil
					end
        end
        t.column(:category) { |payment| payment.category.name_label rescue nil }
      end
		end if Payment.debit.paid.cash_or_cheque.on(criterion_report.report_date).present?

		panel 'Payments (Expenditure)' do
			table_for Payment.credit.paid.cash.on(criterion_report.report_date).order(:id) do |t|
        t.column(:id) { |payment| link_to(payment.id, admin_payment_path(payment)) }
        t.column(:period) { |payment| payment.period_label}
        t.column(:amount) { |payment| number_to_currency(payment.amount, :unit => 'Rs. ', :precision => 0) }
        t.column(:discount) { |payment| number_to_currency(payment.discount, :unit => 'Rs. ', :precision => 0) }
        t.column(:payment_method) { |payment| status_tag(payment.payment_method_label, payment.payment_method_tag) }
        t.column(:paid_to) do |payment|
        	if payment.payable.is_a?(Enrollment)
						link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) rescue nil
					elsif payment.payable.is_a?(Teacher)
						link_to(payment.payable.name, admin_teacher_path(payment.payable)) rescue nil
					end
        end
        t.column(:category) { |payment| payment.category.name_label rescue nil }
      end
		end if Payment.credit.paid.cash.on(criterion_report.report_date).present?

		panel 'Graphs' do
			chart = Gchart.pie_3d(:data => [criterion_report.net_revenue, criterion_report.expenditure], :size => '600x200', :labels => ['Revenue', 'Expenditure'])
      image_tag(chart)
     end

		active_admin_comments
	end

	member_action :update_report, :method => :put do
    criterion_report = CriterionReport.find(params[:id])
    criterion_report.update_report_data
    redirect_to_back
  end

  action_item :only => :show do
    span link_to('Update', update_report_admin_criterion_report_path(criterion_report), :method => :put)
  end
end
