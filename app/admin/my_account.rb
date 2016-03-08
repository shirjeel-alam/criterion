ActiveAdmin.register_page 'My Account' do
  menu parent: 'Account Actions', priority: 3

  controller do
    def index
      redirect_to admin_criterion_account_path(current_admin_user.criterion_account)
    end
  end
end
