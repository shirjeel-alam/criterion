class AddColumnsToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :role, :integer
    add_column :admin_users, :user_id, :integer
    add_column :admin_users, :user_type, :string
    add_column :admin_users, :status, :boolean, :default => true

    AdminUser.reset_column_information
    AdminUser.update_all("status = '1'")

    # Create a default user
    AdminUser.create!(:email => 'admin@example.com', :password => 'password', :password_confirmation => 'password', :role => AdminUser::SUPER_ADMIN, :status => AdminUser::ACTIVE)
  end
end
