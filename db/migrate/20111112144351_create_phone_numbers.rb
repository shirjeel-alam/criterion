class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.string :number
      t.integer :category
      t.integer :contactable_id
      t.string :contactable_type

      t.timestamps
    end
  end
end
