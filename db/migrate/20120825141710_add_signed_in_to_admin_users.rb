class AddSignedInToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :signed_in, :boolean, default: false
  end
end
