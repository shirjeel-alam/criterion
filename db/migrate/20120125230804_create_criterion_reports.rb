class CreateCriterionReports < ActiveRecord::Migration
  def change
    create_table :criterion_reports do |t|
      t.date :report_date
      t.integer :gross_revenue
      t.integer :discounts
      t.integer :net_revenue
      t.integer :expenditure
      t.integer :balance

      t.timestamps
    end
  end
end
