ActiveAdmin.register Payment do
  menu false
  
  member_action :pay, :method => :put do
    payment = Payment.find(params[:id])
    payment.update_attributes(:status => true, :paid_on => Date.today) ? flash[:notice] = 'Payment successfully made.' : flash[:notice] = 'Error in processing payment.'
    redirect_to admin_enrollment_path(payment.payable)
  end
end
