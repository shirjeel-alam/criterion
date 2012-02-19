class AddColumnsToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :role, :integer
    add_column :admin_users, :user_id, :integer
    add_column :admin_users, :user_type, :string
    add_column :admin_users, :status, :boolean, :default => true
  end
end
