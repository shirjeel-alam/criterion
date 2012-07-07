class AddClosedToCriterionReport < ActiveRecord::Migration
  def change
    add_column :criterion_reports, :closed, :boolean, default: false
  end
end
