class Session < ActiveRecord::Base
  has_many :courses
  
  scope :valid, lambda { where('year >= ?', Date.today.year) }
  
  validates :period, :uniqueness => { :scope => :year }
  
  def self.get_session_periods
    [["May/June", 0], ["Oct/Nov", 1]]
  end
  
  def self.get_session_years
    (Date.today.year..(Date.today + 5.years).year).to_a
  end
  
  ### View Helpers ###
  
  def title
    session_output
  end
  
  def session_output
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
  
  def session_period_output
    case period
      when 0
        'May/June'
      when 1
        'Oct/Nov'
    end
  end
end
