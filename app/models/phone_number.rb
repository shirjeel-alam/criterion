class PhoneNumber < ActiveRecord::Base
  belongs_to :contactable, :polymorphic => true

  ### Class Methods ###

  def self.categories
    [["Mobile", 0], ["Home", 1], ["Work", 2], ["General", 3]]
  end

  ### View Helpers ###

  def label
    "#{number} - #{category}"
  end

end
