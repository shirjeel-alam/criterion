class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :name
      t.integer :amount
      t.float :share
      t.references :course

      t.timestamps
    end
    add_index :books, :course_id
  end
end
