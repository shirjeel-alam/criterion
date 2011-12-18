class PhoneNumber < ActiveRecord::Base
  belongs_to :contactable, :polymorphic => true
  
  MOBILE, HOME, WORK, GENERAL = 0, 1, 2, 3

  ### Class Methods ###

  def self.categories
    [['Mobile', MOBILE], ['Home', HOME], ['Work', WORK], ['General', GENERAL]]
  end

  ### View Helpers ###

  def label
    "#{number} - #{category_label}"
  end
  
  def category_label
    case category
    when MOBILE
      'Mobile'
    when HOME
      'Home'
    when WORK
      'Work'
    when GENERAL
      'General'
    end
  end

end
