class CreateCriterionSms < ActiveRecord::Migration
  def change
    create_table :criterion_sms do |t|
      t.string :to
      t.text :message
      t.integer :sender_id
      t.string :sender_type
      t.integer :receiver_id
      t.string :receiver_type
      t.boolean :status

      t.timestamps
    end
  end
end
