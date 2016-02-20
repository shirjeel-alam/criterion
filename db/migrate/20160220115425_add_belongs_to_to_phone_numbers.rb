class AddBelongsToToPhoneNumbers < ActiveRecord::Migration
  def change
    add_column :phone_numbers, :belongs_to, :integer
  end
end
