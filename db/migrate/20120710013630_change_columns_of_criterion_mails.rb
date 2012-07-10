class ChangeColumnsOfCriterionMails < ActiveRecord::Migration
  def up
    change_column :criterion_mails, :to, :text
    change_column :criterion_mails, :cc, :text
    change_column :criterion_mails, :bcc, :text
  end

  def down
    change_column :criterion_mails, :to, :string
    change_column :criterion_mails, :cc, :string
    change_column :criterion_mails, :bcc, :string
  end
end
