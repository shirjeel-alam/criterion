ActiveAdmin.register AdminUser do
  filter :id
  filter :email
  
  index do
    column 'ID', :sortable => :id do |admin|
      link_to(admin.id, admin_admin_user_path(admin))
    end
    column :email
    column :role, :sortable => :role do |admin|
      admin.role_label
    end
    column :user do |admin|
      case admin.role
      when AdminUser::TEACHER
        link_to(admin.user.name, admin_teacher_path(admin.user)) rescue nil
      when AdminUser::STUDENT
        link_to(admin.user.name, admin_student_path(admin.user)) rescue nil
      end
    end
    column :status, :sortable => :status do |admin|
      status_tag(admin.status_label, admin.status_tag)
    end
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    
    default_actions
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :email, :required => true
      f.input :password, :type => :password, :required => true
      f.input :role, :as => :select, :collection => AdminUser.admin_roles, :include_blank => false, :required => true
      f.input :status, :as => :select, :collection => AdminUser.statuses, :include_blank => false, :required => true
    end
    
    f.buttons
  end
end
