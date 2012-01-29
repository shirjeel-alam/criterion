ActiveAdmin.register StudentRegistrationFee do
	menu :parent => 'More Menus', :if => proc { current_admin_user.super_admin? }
	
  member_action :pay, :method => :put do
  	student_registration_fee = StudentRegistrationFee.find(params[:id])
  	student_registration_fee.pay! ? flash[:notice] = 'Payment successfully made.' : flash[:notice] = 'Error in processing payment.'
  	redirect_to_back
  end

  member_action :void, :method => :put do
    student_registration_fee = StudentRegistrationFee.find(params[:id])
    student_registration_fee.void! ? flash[:notice] = 'Payment successfully voided.' : flash[:notice] = 'Error in processing payment.'
    redirect_to_back
  end
end
