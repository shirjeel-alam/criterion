class ChangeColumnsFromStudentRegistrationFees < ActiveRecord::Migration
  def up
    add_column :student_registration_fees, :registration_fee_date, :date
    remove_column :student_registration_fees, :paid_on

    remove_column :student_registration_fees, :status
    add_column :student_registration_fees, :status, :integer, :default => StudentRegistrationFee::DUE
  end

  def down
    remove_column :student_registration_fees, :registration_fee_date
    add_column :student_registration_fees, :paid_on , :date
  end
end
