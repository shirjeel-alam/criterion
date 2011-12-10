class Course < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :session
  
  has_many :enrollments
  has_many :payments, :through => :enrollments
  has_many :students, :through => :enrollments
  
  before_save :update_status, :set_end_date
  after_save :create_payments
  
  validates_presence_of :name, :teacher, :session, :monthly_fee
  
  NOT_STARTED = 0
  IN_PROGRESS = 1
  COMPLETED = 2
  CANCELLED = 3
  
  def update_status
    self.status = start_date.blank? ? NOT_STARTED : (start_date.future? ? NOT_STARTED : IN_PROGRESS)
    self.status = end_date.future? ? IN_PROGRESS : COMPLETED unless end_date.blank?
  end
  
  #Assuming that the end date will always coincide with the end of session
  def set_end_date
    if self.end_date.nil?
      case session.period
      when 0
        self.end_date = Date.parse("May #{session.year}")
      when 1
        self.end_date = Date.parse("October #{session.year}")
      end
    end
  end
  
  def create_payments
    if start_date.present? && end_date.present?
      enrollments.each do |enrollment|
        enrollment.create_payments
      end
    end
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

  ### Class Methods ###
  
  def self.get_all
    Course.all.collect { |c| [c.course_output, c.id] }
  end

  def self.get_active
    # Pending implementation
  end
 
  def self.statuses
    [['Not Started', 0], ['In Progress', 1], ['Completed', 2], ['Cancelled', 3]]
  end

  ### View Helpers ###

  def label 
    "#{self.name} | #{self.teacher.name}"
  end

  def title
    "#{self.name} #{session.label}"
  end

  def status_label
    case course.status
      when 0
        'Not Started'
      when 1
        'In Progress'
      when 2
        'Completed'
      when 3
        'Cancelled'
    end
  end

  def status_tag
    case course.status
      when 0
        :warning
      when 1
        :ok
      when 2
        :ok
      when 3
        :error
    end
  end
end
