ActiveAdmin.register CriterionReport do
	menu :priority => 2, :if => proc { current_admin_user.super_admin? || current_admin_user.admin? }
	
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
	end

	show do
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

		active_admin_comments
	end
end
