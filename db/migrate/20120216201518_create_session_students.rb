class CreateSessionStudents < ActiveRecord::Migration
  def change
    create_table :sessions_students do |t|
      t.integer :student_id
      t.integer :session_id
      t.integer :payment_id

      t.timestamps
    end
  end
end
