ActiveAdmin.register Payment, as: 'Expenditure' do
	menu priority: 2, if: proc { current_admin_user.super_admin_or_partner? || current_admin_user.admin? }

	actions :index

	filter :id
	filter :amount
	filter :period
	filter :category, as: :select, collection: proc { Category.categories }, input_html: { class: 'chosen-select' }
	filter :payment_method, as: :select, collection: proc { Payment.payment_methods }, input_html: { class: 'chosen-select' }

	scope :all, default: true do |payments|
		Payment.expenditure
	end
	scope :this_month do |payments|
		Payment.expenditure.on(Payment.month(Time.current.to_date))
	end
	scope :last_month do |payments|
		Payment.expenditure.on(Payment.month(Time.current.to_date << 1))
	end
	scope :first_quarter do |payments|
		Payment.expenditure.on(Payment.quarter(Time.current.to_date.year, 1))
	end
	scope :second_quarter do |payments|
		Payment.expenditure.on(Payment.quarter(Time.current.to_date.year, 2))
	end
	scope :third_quarter do |payments|
		Payment.expenditure.on(Payment.quarter(Time.current.to_date.year, 3))
	end
	scope :fourth_quarter do |payments|
		Payment.expenditure.on(Payment.quarter(Time.current.to_date.year, 4))
	end

	index do
		column 'ID', sortable: :id do |payment|
			link_to(payment.id, admin_payment_path(payment))
		end
		column :payment_date, sortable: :payment_date do |payment|
      date_format(payment.payment_date)
    end
		column :category, sortable: :category_id do |payment|
			payment.category.name_label rescue nil
		end
		column :amount, sortable: :amount do |payment|
			number_to_currency(payment.amount, unit: 'Rs. ', precision: 0)
		end
		column :status, sortable: :status do |payment|
			status_tag(payment.status_label, payment.status_tag)
		end
    column :payment_method, sortable: :payment_method do |payment|
      status_tag(payment.payment_method_label, payment.payment_method_tag)
    end
	end

	action_item only: :index do
		span link_to('New Expenditure', new_admin_payment_path(payment: { status: Payment::PAID, payment_date: Time.current.to_date, payment_type: Payment::CREDIT }))
	end
end