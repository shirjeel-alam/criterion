class AddStatusToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :status, :integer
  end
end
