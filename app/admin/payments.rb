ActiveAdmin.register Payment do
  menu false

  form :partial => 'form'

  show do
    attributes_table_for payment do
      row(:id) { payment.id }
      row(:payable) { payment.payable }
      row(:payable_type) { payment.payable_type }
      row(:period) { payment.period_label }
      row(:amount) { number_to_currency(payment.net_amount, :unit => 'Rs. ', :precision => 0) }
      row(:status) { status_tag(payment.status_label, payment.status_tag) }
      row(:payment_type) { status_tag(payment.type_label, payment.type_tag) }
      row(:discount) { number_to_currency(payment.discount, :unit => 'Rs. ', :precision => 0) }
    end
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
        @payment = @teacher.withdrawals.build(:payment_type => Payment::DEBIT, :status => Payment::PAID, :payment_date => Date.today)
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
