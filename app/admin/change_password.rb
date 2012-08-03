ActiveAdmin.register_page 'Change Password' do
  menu parent: 'Account Actions', priority: 3
  
  controller do
    def index
      redirect_to change_password_admin_admin_user_path(current_admin_user)
    end
  end
end