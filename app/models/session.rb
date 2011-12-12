class Session < ActiveRecord::Base
  has_many :courses
  
  scope :active, lambda { where('year >= ?', Date.today.year) }
  
  validates :period, :uniqueness => { :scope => :year }
 
  ### Class Methods ###

  def self.periods
    [["May/June", 0], ["Oct/Nov", 1]]
  end
  
  def self.years
    (Date.today.year..(Date.today + 5.years).year).to_a
  end
  
  def self.get_all
    Session.all.collect { |s| [s.label, s.id] }
  end

  def self.get_active
    Session.active.collect { |s| [s.label, s.id] } 
  end
  
  ### View Helpers ###
  
  def title
    label
  end
  
  def label
    result = ""
    case period
      when 0
        result << 'May/June'
      when 1
        result << 'Oct/Nov'
    end
    
    result << " #{year}"
    result
  end
  
  def period_label
    case period
      when 0
        'May/June'
      when 1
        'Oct/Nov'
    end
  end
end
