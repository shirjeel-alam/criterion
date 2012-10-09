class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.time :start
      t.time :end
      t.string :day
      t.integer :room
      t.references :course

      t.timestamps
    end
  end
end
