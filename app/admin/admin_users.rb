ActiveAdmin.register AdminUser do
  filter :id
  filter :email
  
  index do
    column 'ID', :sortable => :id do |admin|
      link_to(admin.id, admin_admin_user_path(admin))
    end
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    
    default_actions
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password, :type => :password
    end
    
    f.buttons
  end
end
