class AddStatusToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :status, :integer

    Session.reset_column_information
    Session.find_each do |session|
    	session.update_status
    	session.save
    end
  end
end
