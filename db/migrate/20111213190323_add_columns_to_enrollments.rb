class AddColumnsToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :enrollment_date, :date
    add_column :enrollments, :enrollment_date_for, :boolean, :default => nil
  end
end
