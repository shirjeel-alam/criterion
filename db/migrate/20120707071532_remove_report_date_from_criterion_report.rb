class RemoveReportDateFromCriterionReport < ActiveRecord::Migration
  def up
    CriterionReport.reset_column_information
    CriterionReport.all.each do |cr|
      cr.criterion_report_dates.create!(report_date: cr.report_date)
    end

    CriterionReport.all.map(&:close!)
    CriterionReport.last.open!

    remove_column :criterion_reports, :report_date
  end

  def down
    add_column :criterion_reports, :report_date, :date
  end
end
