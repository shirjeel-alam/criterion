class CreateCriterionMonthlyReports < ActiveRecord::Migration
  def change
    create_table :criterion_monthly_reports do |t|
      t.date :report_month
      t.integer :revenue
      t.integer :expenditure
      t.integer :balance

      t.timestamps
    end
  end
end
