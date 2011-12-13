class AddColumnsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :course_date, :date
    add_column :courses, :course_date_for, :boolean, :default => nil
  end
end
