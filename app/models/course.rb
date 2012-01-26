class Course < ActiveRecord::Base
  NOT_STARTED, IN_PROGRESS, COMPLETED, CANCELLED = 0, 1, 2, 3
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
    if start_date.blank? || start_date > Date.today
      self.status = NOT_STARTED
    elsif start_date <= Date.today || end_date > Date.today
      self.status = IN_PROGRESS
    elsif end_date >= Date.today
      self.status = COMPLETED
    else
      self.status = CANCELLED
    end unless (completed? || cancelled?)
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

  def start!
    self.update_attributes(:status => IN_PROGRESS, :course_date => Date.today, :start_date => Date.today)
    start_enrollments
  end

  def complete!
    self.update_attributes(:status => COMPLETED, :course_date => Date.today, :end_date => Date.today)
    complete_enrollments
  end

  def cancel!
    self.update_attributes(:status => CANCELLED, :course_date => Date.today)
    cancel_enrollments
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
    Student.all.collect { |student| student unless self.has_enrollment?(student) }.compact.uniq
  end

  def emails
    students.collect { |student| ["#{student.name} - #{student.email}", student.email]  if student.email.present? }.compact.uniq
  end

  def phone_numbers
    students.collect { |student| ["#{student.name} - #{student.phone_numbers.mobile.first.number}", student.phone_numbers.mobile.first.number] if student.phone_numbers.mobile.first.present? }.compact.uniq
  end

  def start_enrollments
    enrollments.collect { |enrollment| enrollment if enrollment.not_started? && enrollment.start_date <= start_date }.compact.each do |enrollment|
      enrollment.start!
    end
  end

  def complete_enrollments
    enrollments.collect { |enrollment| enrollment unless enrollment.cancelled? || enrollment.completed? }.compact.each do |enrollment|
      enrollment.complete!
    end
  end

  def cancel_enrollments
    enrollments.collect { |enrollment| enrollment unless enrollment.cancelled? || enrollment.completed? }.compact.each do |enrollment|
      enrollment.cancel!
    end
  end

  def update_course
    last_status = status
    update_status
    current_status = status
    
    unless last_status == current_status
      case current_status
      when IN_PROGRESS
        start!
      when COMPLETED
        complete!
      when CANCELLED
        cancel!
      end
    end
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
end
