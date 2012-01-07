class CreateMails < ActiveRecord::Migration
  def change
    create_table :mails do |t|
      t.string :from
      t.string :to
      t.string :cc
      t.string :bcc
      t.string :subject
      t.text :body
      t.integer :mailable_id
      t.string :mailable_type

      t.timestamps
    end
  end
end
