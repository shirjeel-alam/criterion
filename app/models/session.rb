class Session < ActiveRecord::Base
  has_many :courses
  
  scope :active, lambda { where('year >= ?', Date.today.year) }
  scope :completed, lambda { where('year < ?', Date.today.year) }
  
  validates :period, :uniqueness => { :scope => :year }
  
  JANUARY, FEBRUARY, MARCH, APRIL, MAY, JUNE, JULY, AUGUST, SEPTEMBER, OCTOBER, NOVEMBER, DECEMBER = Range.new(1, 12).to_a
  MAY_JUNE, OCT_NOV = 0, 1
  
  def active?
    self == Session.get_active
  end
 
  ### Class Methods ###

  def self.periods
    [["May/June", MAY_JUNE], ["Oct/Nov", OCT_NOV]]
  end
  
  def self.years
    (Date.today.year..(Date.today + 5.years).year).to_a
  end
  
  def self.get_all
    Session.all.collect { |s| [s.label, s.id] }
  end

  def self.get_active
    #Session.active.collect { |s| [s.label, s.id] }
    period, year = nil, nil
    if Range.new(JANUARY..JULY).include?(Date.today.month)
      period = MAY_JUNE
      year = Date.today.year
    elsif Range.new(AUGUST..NOVEMBER).include?(Date.today.month)
      period = OCT_NOV
      year = Date.today.year
    else
      period = MAY_JUNE
      year = Date.today.year + 1
    end
    
    Session.find_by_period_and_year(period, year)
  end
  
  ### View Helpers ###
  
  def title
    label
  end
  
  def label
    result = ""
    case period
      when MAY_JUNE
        result << 'May/June'
      when OCT_NOV
        result << 'Oct/Nov'
    end
    
    result << " #{year}"
    result
  end
  
  def period_label
    case period
      when MAY_JUNE
        'May/June'
      when OCT_NOV
        'Oct/Nov'
    end
  end
end
