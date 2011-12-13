class AddStatusToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :status, :integer
  end
end
