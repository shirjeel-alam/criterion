class AddDiscountAppliedToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :discount_applied, :boolean, default: false
  end
end
