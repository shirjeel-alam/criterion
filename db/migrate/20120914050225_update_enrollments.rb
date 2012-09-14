class UpdateEnrollments < ActiveRecord::Migration
  def up
    Enrollment.all.map(&:save)
  end

  def down
  end
end
