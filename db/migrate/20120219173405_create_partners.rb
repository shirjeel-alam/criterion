class CreatePartners < ActiveRecord::Migration
  def change
    create_table :partners do |t|
      t.string :name
      t.string :email
      t.float :share

      t.timestamps
    end
  end
end
