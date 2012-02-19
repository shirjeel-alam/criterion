ActiveAdmin.register Payment, :as => 'Expenditure' do
	menu :priority => 2, :if => proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? }

	actions :index

	filter :id
	filter :amount
	filter :period
	filter :category, :as => :select, :collection => lambda { Category.categories }
	filter :payment_method, :as => :select, :collection => lambda { Payment.payment_methods }

	scope :all, :default => true do |payments|
		Payment.expenditure
	end
	scope :this_month do |payments|
		Payment.expenditure.on(Payment.month(Date.today))
	end
	scope :last_month do |payments|
		Payment.expenditure.on(Payment.month(Date.today << 1))
	end
	scope :first_quarter do |payments|
		Payment.expenditure.on(Payment.quarter(Date.today.year, 1))
	end
	scope :second_quarter do |payments|
		Payment.expenditure.on(Payment.quarter(Date.today.year, 2))
	end
	scope :third_quarter do |payments|
		Payment.expenditure.on(Payment.quarter(Date.today.year, 3))
	end
	scope :fourth_quarter do |payments|
		Payment.expenditure.on(Payment.quarter(Date.today.year, 4))
	end

	index do
		column 'ID', :sortable => :id do |payment|
			link_to(payment.id, admin_payment_path(payment))
		end
		column :period, :sortable => :period do |payment|
			payment.period_label
		end
		column :amount, :sortable => :amount do |payment|
			number_to_currency(payment.amount, :unit => 'Rs. ', :precision => 0)
		end
		column :discount, :sortable => :discount do |payment|
			number_to_currency(payment.discount, :unit => 'Rs. ', :precision => 0)
		end
		column :status, :sortable => :status do |payment|
			status_tag(payment.status_label, payment.status_tag)
		end
		column :payment_type, :sortable => :payment_type do |payment|
			status_tag(payment.type_label, payment.type_tag)
		end
		column :payment_date, :sortable => :payment_date do |payment|
      date_format(payment.payment_date)
    end
    column :payment_method, :sortable => :payment_method do |payment|
      status_tag(payment.payment_method_label, payment.payment_method_tag)
    end
		column :payable do |payment|
			if payment.payable.is_a?(Enrollment)
				link_to(payment.payable.student.name, admin_student_path(payment.payable.student)) rescue nil
			elsif payment.payable.is_a?(Teacher)
				link_to(payment.payable.name, admin_teacher_path(payment.payable)) rescue nil
			end
		end
		column :category, :sortable => :category_id do |payment|
			payment.category.name_label rescue nil
		end
		# column nil do |payment|
		# 	span link_to('View', admin_payment_path(payment))	
		# 	span link_to('Edit', edit_admin_payment_path(payment))
		# 	span link_to('Delete', admin_payment_path(payment), :method => :delete)
		# end

		# default_actions
	end

	action_item :only => :index do
		span link_to('New Expenditure', new_admin_payment_path(:payment => { :status => Payment::PAID, :payment_date => Date.today, :payment_type => Payment::CREDIT }))
	end
end