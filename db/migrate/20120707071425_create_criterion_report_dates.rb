class CreateCriterionReportDates < ActiveRecord::Migration
  def change
    create_table :criterion_report_dates do |t|
      t.date :report_date
      t.integer :criterion_report_id

      t.timestamps
    end
  end
end
