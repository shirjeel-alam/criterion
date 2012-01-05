class AddStartDateToEnrollment < ActiveRecord::Migration
  def change
    add_column :enrollments, :start_date, :date
  end
end
