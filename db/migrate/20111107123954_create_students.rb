class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :name
      t.string :address
      t.integer :registration_fee
      t.boolean :fee_status, :default => false

      t.timestamps
    end
  end
end
