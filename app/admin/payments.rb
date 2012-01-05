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
      row(:paid_on) { payment.date_label }
      row(:discount) { number_to_currency(payment.discount, :unit => 'Rs. ', :precision => 0) }
    end
  end
  
  member_action :pay, :method => :put do
    payment = Payment.find(params[:id])
    payment.update_attributes(:status => true, :paid_on => Date.today) ? flash[:notice] = 'Payment successfully made.' : flash[:notice] = 'Error in processing payment.'
    redirect_to :back
  end

  collection_action :pay_cumulative, :method => :put do
  	payments = Payment.find(params[:payments])
  	count = 0
  	payments.each do |payment|
  		unless payment.paid?
  			payment.update_attributes(:status => true, :paid_on => Date.today) 
  			count += 1
  		end
  	end
  	flash[:notice] = "#{count} payment(s) successfully made."
  	redirect_to :back
  end

  controller do
    def new
      if params[:teacher_id]
        @teacher = Teacher.find(params[:teacher_id])
        @payment = @teacher.withdrawals.build(:payment_type => Payment::DEBIT, :status => Payment::PAID, :paid_on => Date.today)
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
