ActiveAdmin.register Payment do
  menu :parent => 'More Menus', :if => proc { current_admin_user.super_admin? }

  filter :id
  filter :amount
  filter :status, :as => :select, :collection => lambda { Payment.statuses }
  filter :payment_type, :as => :select, :collection => lambda { Payment.payment_types }
  filter :category, :as => :select, :collection => lambda { Category.categories }

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

  form :partial => 'form'

  show do
    panel 'Payment Details' do
      attributes_table_for payment do
        row(:id) { payment.id }
        row(:payable) { payment.payable }
        row(:payable_type) { payment.payable_type }
        row(:period) { payment.period_label }
        row(:amount) { number_to_currency(payment.net_amount, :unit => 'Rs. ', :precision => 0) }
        row(:discount) { number_to_currency(payment.discount, :unit => 'Rs. ', :precision => 0) }
        row(:status) { status_tag(payment.status_label, payment.status_tag) }
        row(:payment_type) { status_tag(payment.type_label, payment.type_tag) }
        row(:payment_date) { date_format(payment.payment_date) }
        row(:category) { payment.category.name_label rescue nil }
      end
    end

    active_admin_comments
  end
  
  member_action :pay, :method => :put do
    payment = Payment.find(params[:id])
    payment.pay! ? flash[:notice] = 'Payment successfully made.' : flash[:notice] = 'Error in processing payment.'
    redirect_to_back
  end

  member_action :void, :method => :put do
    payment = Payment.find(params[:id])
    payment.void! ? flash[:notice] = 'Payment successfully voided.' : flash[:notice] = 'Error in processing payment.'
    redirect_to_back
  end
  
  member_action :refund, :method => :put do
    payment = Payment.find(params[:id])
    payment.refund! ? flash[:notice] = 'Payment successfully refunded.' : flash[:notice] = 'Error in processing payment.'
    redirect_to_back
  end

  collection_action :pay_cumulative, :method => :put do
  	payments = Payment.find(params[:payments])
  	count = 0
  	payments.each do |payment|
  		if payment.due?
  			payment.pay!
  			count += 1
  		end
  	end
  	flash[:notice] = "#{count} payment(s) successfully made."
  	redirect_to_back
  end

  controller do
    before_filter :check_authorization

    def check_authorization
      unless current_admin_user.super_admin?
        flash[:error] = 'You are not authorized to perform this action'
        redirect_to_back
      end
    end

    def new
      if params[:teacher_id]
        @teacher = Teacher.find(params[:teacher_id])
        @payment = @teacher.withdrawals.build(:payment_type => Payment::DEBIT, :status => Payment::PAID, :payment_date => Date.today, :category => Category.find_by_name(Category::TEACHER_FEE))
      else
        @payment = Payment.new  
      end
    end

    def create
      @payment = Payment.new(params[:payment])
      
      if @payment.save
        flash[:notice] = 'Withdrawal successfully created'
        redirect_to admin_teacher_path(@payment.payable)
      else
        render :new
      end
    end
  end
end
