ActiveAdmin.register Payment do
  # menu false

  form :partial => 'form'
  
  member_action :pay, :method => :put do
    payment = Payment.find(params[:id])
    payment.update_attributes(:status => true, :paid_on => Date.today) ? flash[:notice] = 'Payment successfully made.' : flash[:notice] = 'Error in processing payment.'
    redirect_to :back
  end

  collection_action :pay_cumulative, :method => :put do
  	payments = Payment.find(params[:payments])
  	count = 0
  	payments.each do |payment|
  		unless payment.status
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