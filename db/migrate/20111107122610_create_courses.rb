class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.integer :teacher_id
      t.integer :session_id
      t.integer :monthly_fee
      t.integer :status
      t.date :start_date
      t.date :end_date
      #t.integer :bulk_fee #can be catered for later

      t.timestamps
    end
  end
end
