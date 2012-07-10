class AddApiResponseToCriterionSms < ActiveRecord::Migration
  def change
    add_column :criterion_sms, :api_response, :text
  end
end
