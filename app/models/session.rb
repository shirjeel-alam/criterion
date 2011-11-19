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
end
