class Course < ActiveRecord::Base
  NOT_STARTED, IN_PROGRESS, COMPLETED, CANCELLED = 0, 1, 2, 3
  COMPLETION, CANCELLATION = true, false
  O_LEVEL, AS_LEVEL, A2_LEVEL = 0, 1, 2
  
  belongs_to :teacher
  belongs_to :session
  
  has_many :enrollments, :dependent => :destroy
  has_many :payments, :through => :enrollments
  has_many :students, :through => :enrollments
  
  before_validation :set_end_date

  before_save :update_status
  after_save :create_payments
  
  validates :name, :presence => true
  validates :teacher_id, :presence => true
  validates :session_id, :presence => true
  validates :status, :presence => true, :inclusion => { :in => [NOT_STARTED, IN_PROGRESS, COMPLETED, CANCELLED] }
  validates :monthly_fee, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :start_date, :timeliness => { :type => :date, :before => lambda { end_date }, :allow_blank => true } 
  validates :end_date, :timeliness => { :type => :date, :allow_blank => true }
  validates :level, :presence => true, :inclusion => { :in => [O_LEVEL, AS_LEVEL, A2_LEVEL] }

  scope :active, where(:status => [NOT_STARTED, IN_PROGRESS])
  scope :not_started, where(:status => NOT_STARTED)
  scope :in_progress, where(:status => IN_PROGRESS)
  scope :completed, where(:status => COMPLETED)
  scope :cancelled, where(:status => CANCELLED)
  
  def update_status
    if start_date.blank? || start_date.try(:future?)
      self.status = NOT_STARTED
    elsif start_date.try(:past?) || end_date.try(:future?)
      self.status = IN_PROGRESS
    elsif end_date.try(:past?) || end_date == Date.today
      self.status = COMPLETED
    else
      self.status = CANCELLED
    end unless (completed? || cancelled?)
  end
  
  def enrollments_update_status
    enrollments.map(&:update_status)
  end

  def set_end_date    
    case session.period
      when Session::MAY_JUNE
        self.end_date = Date.parse("May #{session.year}")
      when Session::OCT_NOV
        self.end_date = Date.parse("October #{session.year}")
    end unless end_date.present?
  end
  
  def create_payments    
    enrollments.each do |enrollment|
      enrollment.create_payments
    end if started?
  end
  
  def calculate_revenue
    months = months_between(course.start_date, course.end_date)
    months.each do |date|
      calculate_month_revenue(date)
    end
  end
  
  def calculate_month_revenue(date)
    revenue = 0
    curr_payments = payments.paid.where(:period => date.beginning_of_month..date.end_of_month)
    curr_payments.each do |payment|
      revenue += payment.amount
    end
    revenue
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
  
  def has_enrollment?(student)
    enrollments.collect(&:student_id).compact.include?(student.id)
  end
  
  def months_between(start_date, end_date)
    months = []
    months << start_date
    ptr = start_date >> 1
    while ptr < end_date do
      months << ptr.beginning_of_month
      ptr = ptr >> 1
    end
    months << end_date if start_date.beginning_of_month != end_date.beginning_of_month
    months      
  end
  
  def not_enrolled_students
    Student.all.collect { |s| s unless self.has_enrollment?(s) }.compact.uniq
  end

  def emails
    students.collect { |s| ["#{s.name} - #{s.email}", s.email] }
  end

  ### Class Methods ###
  
  def self.get_all
    Course.all.collect { |c| [c.label, c.id] }
  end

  def self.get_active
    Course.active.collect { |c| [c.label, c.id] }
  end

  def self.statuses
    [['Not Started', NOT_STARTED], ['In Progress', IN_PROGRESS], ['Completed', COMPLETED], ['Cancelled', CANCELLED]]
  end

  def self.levels
    [['O-Level', O_LEVEL], ['AS-Level', AS_LEVEL], ['A2-Level', A2_LEVEL]]
  end

  ### View Helpers ###

  def label 
    "#{name} | #{teacher.name}"
  end

  def title
    "#{name} #{session.label rescue nil}"
  end

  def level_label
    case level
      when O_LEVEL
        'O-Level'
      when AS_LEVEL
        'AS-Level'
      when A2_LEVEL
        'A2-Level'
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

  def course_date_for_label
    return 'N/A' if course_date_for.nil?
     
    case course_date_for
      when CANCELLATION
        'Cancellation'
      when COMPLETION
        'Completion'
    end 
  end

  def course_date_for_tag
    return :warning if course_date_for.nil?
    
    case course_date_for
      when CANCELLATION
        :error
      when COMPLETION
        :ok
    end
  end
end
