class Session < ActiveRecord::Base
  NOT_STARTED, IN_PROGRESS, COMPLETED, CANCELLED = 0, 1, 2, 3

  has_many :courses, :dependent => :destroy
  has_many :session_students
  has_many :students, :through => :session_students
  has_many :registration_fees, :through => :session_students

  accepts_nested_attributes_for :courses

  JANUARY, FEBRUARY, MARCH, APRIL, MAY, JUNE, JULY, AUGUST, SEPTEMBER, OCTOBER, NOVEMBER, DECEMBER = Range.new(1, 12).to_a
  MAY_JUNE, OCT_NOV = 0, 1

  before_validation :set_status
  
  validates :period, :presence => true, :inclusion => { :in => [MAY_JUNE, OCT_NOV] }, :uniqueness => { :scope => :year }
  validates :status, :presence => true, :inclusion => { :in => [NOT_STARTED, IN_PROGRESS, COMPLETED, CANCELLED] }
  validates :year, :presence => true, :numericality => { :only_integer => true }
  validates :registration_fee, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }

  scope :active, where(:status => [NOT_STARTED, IN_PROGRESS])
  scope :not_started, where(:status => NOT_STARTED)
  scope :in_progress, where(:status => IN_PROGRESS)
  scope :completed, where(:status => COMPLETED)
  scope :cancelled, where(:status => CANCELLED)
  
  def active?
    year >= Date.today.year
  end

  def set_status
    self.status = NOT_STARTED unless status.present?
  end

  def update_status
    if courses.active.present? 
      if courses.in_progress.present?
        self.status = IN_PROGRESS
      else
        self.status = NOT_STARTED
      end
    else
      self.status = COMPLETED
    end unless (completed? || cancelled?)
  end

  def not_started?
    status == NOT_STARTED
  end

  def started?
    status == IN_PROGRESS
  end
  
  def completed?
    status == COMPLETED
  end

  def cancelled?
    status == CANCELLED
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
    Session.active.collect { |s| [s.label, s.id] }
  end

  def self.statuses
    [['Not Started', NOT_STARTED], ['In Progress', IN_PROGRESS], ['Completed', COMPLETED], ['Cancelled', CANCELLED]]
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

  def status_label
    case status
      when NOT_STARTED
        'Not Started'
      when IN_PROGRESS
        'In Progress'
      when COMPLETED
        'Completed'
      when CANCELLED
        'Cancelled'
    end
  end

  def status_tag
    case status
      when NOT_STARTED
        :warning
      when IN_PROGRESS
        :ok
      when COMPLETED
        :ok
      when CANCELLED
        :error
    end
  end
end
