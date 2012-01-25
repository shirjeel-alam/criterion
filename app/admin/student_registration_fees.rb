ActiveAdmin.register StudentRegistrationFee do
	menu :parent => 'More Menus', :if => proc { current_admin_user.super_admin? }
	
  member_action :pay, :method => :put do
  	student_registration_fee = StudentRegistrationFee.find(params[:id])
  	student_registration_fee.update_attributes(:status => true, :paid_on => Date.today) ? flash[:notice] = 'Payment successfully made.' : flash[:notice] = 'Error in processing payment.'
  	redirect_to_back
  end
end
