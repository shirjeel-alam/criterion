class ChangeStatusInCriterionSms < ActiveRecord::Migration
  def up
    change_column :criterion_sms, :status, :boolean, default: false
  end

  def down
    change_column :criterion_sms, :status, :boolean
  end
end
