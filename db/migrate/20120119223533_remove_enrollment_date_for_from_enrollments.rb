class RemoveEnrollmentDateForFromEnrollments < ActiveRecord::Migration
  def up
  	remove_column :enrollments, :enrollment_date_for
  end

  def down
  	add_column :enrollments, :enrollment_date_for, :boolean, :default => nil
  end
end
