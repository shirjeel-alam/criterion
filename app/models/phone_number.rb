class PhoneNumber < ActiveRecord::Base
  belongs_to :contactable, :polymorphic => true
  
  def self.get_phone_number_categories
    [["Mobile", 0], ["Home", 1], ["Work", 2], ["General", 3]]
  end
end
