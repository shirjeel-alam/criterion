class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :period
      t.integer :year

      t.timestamps
    end
  end
end
