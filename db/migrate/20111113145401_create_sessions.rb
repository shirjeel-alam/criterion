class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :period
      t.integer :year
      t.integer :registration_fee

      t.timestamps
    end
  end
end
