ActiveAdmin.register Staff do
  menu :priority => 2, :if => proc { current_admin_user.super_admin? || current_admin_user.admin? }
end
