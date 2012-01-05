class ChangeStatusFromPayments < ActiveRecord::Migration
  def up
    change_column :payments, :status, :integer
  end

  def down
    change_column :payments, :status, :boolean
  end
end
