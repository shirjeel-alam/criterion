ActiveAdmin.register Payment, :as => 'Expenditure' do
	menu :priority => 2, :if => proc { current_admin_user.super_admin? || current_admin_user.admin? }

	actions :index

	filter :id
	filter :amount
	filter :status, :as => :select, :collection => lambda { Payment.statuses }
	filter :payment_type, :as => :select, :collection => lambda { Payment.payment_types }
	filter :category, :as => :select, :collection => lambda { Category.categories }

	scope :all, :default => true do |payments|
		Payment.debit
	end
	scope :teacher_fee
	scope :bills
	scope :misc

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
		column :payable do |payment|
			if payment.payable.is_a?(Student)
				link_to(payment.payable.name, admin_student_path(payment.payable)) rescue nil
			elsif payment.payable.is_a?(Teacher)
				link_to(payment.payable.name, admin_teacher_path(payment.payable)) rescue nil
			end
		end
		column :category, :sortable => :category_id do |payment|
			payment.category.name_label rescue nil
		end

		default_actions
	end

	action_item :only => :index do
		span link_to('New Expenditure', new_admin_payment_path)
	end
end