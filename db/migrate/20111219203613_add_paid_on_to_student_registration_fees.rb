class AddPaidOnToStudentRegistrationFees < ActiveRecord::Migration
  def change
    add_column :student_registration_fees, :paid_on, :date
  end
end
