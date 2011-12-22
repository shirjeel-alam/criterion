class Course < ActiveRecord::Base
  
  NOT_STARTED, IN_PROGRESS, COMPLETED, CANCELLED = 0, 1, 2, 3
  CANCELLATION, COMPLETION = 0, 1
  
  belongs_to :teacher
  belongs_to :session
  
  has_many :enrollments
  has_many :payments, :through => :enrollments
  has_many :students, :through => :enrollments
  
  before_save :set_end_date, :update_status
  after_save :create_payments
  
  validates_presence_of :name, :teacher, :session, :monthly_fee
  
  #TODO: Change to SQL
  scope :active, where(:status => [NOT_STARTED, IN_PROGRESS])
  
  def update_status
    if start_date.blank? || start_date.try(:future?)
      self.status = NOT_STARTED
    elsif end_date.try(:future?)
      self.status = IN_PROGRESS
    elsif end_date.try(:past?)
      self.status = COMPLETED
    else
      self.status = CANCELLED
    end
  end
  
  def enrollments_update_status
    enrollments.map(&:update_status)
  end
  
  #Assuming that the end date will always coincide with the end of session
  def set_end_date    
    case session.period
    when Session::MAY_JUNE
      self.end_date = Date.parse("May #{session.year}")
    when Session::OCT_NOV
      self.end_date = Date.parse("October #{session.year}")
    end unless [COMPLETED, CANCELLED].include?(status)   
  end
  
  def create_payments    
    enrollments.each do |enrollment|
      enrollment.create_payments
    end if started?
  end
  
  def first_month_payment
    ((start_date.end_of_month - start_date).to_f / (start_date.end_of_month - start_date.beginning_of_month).to_f * monthly_fee).to_i
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
  
  def started?
    status == IN_PROGRESS
  end
  
  def completed?
    status == COMPLETED
  end
  
  def has_enrollment?(student)
    enrollments.collect(&:id).include?(student.id)
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

  ### Class Methods ###
  
  def self.get_all
    Course.all.collect { |c| [c.label, c.id] }
  end

  def self.get_active
    Course.active.collect { |c| [c.label, c.id] }
  end
 
  def self.statuses
    [['Not Started', 0], ['In Progress', 1], ['Completed', 2], ['Cancelled', 3]]
  end

  ### View Helpers ###

  def label 
    "#{name} | #{teacher.name}"
  end

  def title
    "#{name} #{session.label}"
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
