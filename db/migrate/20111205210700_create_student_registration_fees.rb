class CreateStudentRegistrationFees < ActiveRecord::Migration
  def change
    create_table :student_registration_fees do |t|
      t.integer :student_id
      t.integer :session_id
      t.boolean :status, :default => false

      t.timestamps
    end
  end
end
