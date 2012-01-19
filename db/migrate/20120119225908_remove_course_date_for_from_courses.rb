class RemoveCourseDateForFromCourses < ActiveRecord::Migration
  def up
  	remove_column :courses, :course_date_for
  end

  def down
  	add_column :courses, :course_date_for, :boolean, :default => nil
  end
end
