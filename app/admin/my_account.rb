ActiveAdmin.register_page 'My Account' do
  controller do
    def index
      redirect_to admin_criterion_account_path(current_admin_user.criterion_account)
    end
  end
end