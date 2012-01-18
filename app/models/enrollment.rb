class Enrollment < ActiveRecord::Base
  
  NOT_STARTED, IN_PROGRESS, COMPLETED, CANCELLED = 0, 1, 2, 3
  COMPLETION, CANCELLATION = true, false
  
  belongs_to :course
  belongs_to :student
  
  has_many :payments, :as => :payable, :dependent => :destroy
  
  validates :course_id, :uniqueness => { :scope => :student_id }
  validates :status, :presence => true, :inclusion => { :in => [NOT_STARTED, IN_PROGRESS, COMPLETED, CANCELLED] }
  validates :start_date, :timeliness => { :type => :date, :allow_blank => true }
  validates :enrollment_date, :timeliness => { :type => :date }, :allow_blank => true
  validates :enrollment_date_for, :inclusion => { :in => [CANCELLATION, COMPLETION] }, :allow_blank => true  

  before_validation :set_start_date, :set_status
  
  after_create :associate_session

  before_save :update_status
  after_save :create_payments, :evaluate_discount
  
  scope :not_started, where(:status => NOT_STARTED)
  scope :in_progress, where(:status => IN_PROGRESS)
  scope :completed, where(:status => COMPLETED)
  scope :cancelled, where(:status => CANCELLED)
  
  def session
    course.session
  end

  def student_id
    student.id rescue nil
  end

  def set_status
    if course.not_started?
      self.status = NOT_STARTED
    else
      self.status = start_date.future? ? NOT_STARTED : IN_PROGRESS
    end unless status.present?
  end

  def set_start_date
    self.start_date = Date.today unless start_date.present? 
  end
  
  def update_status
    if [Course::NOT_STARTED, Course::COMPLETED, Course::CANCELLED].include?(course.status)
      self.status = course.status
    else
      self.start_date = start_date < course.start_date ? course.start_date : start_date
      self.status = start_date.future? ? NOT_STARTED : IN_PROGRESS unless [COMPLETED, CANCELLED].include?(status)
    end
  end
  
  def first_month_payment
    user_date = course.start_date > start_date ? course.start_date : start_date

    if (user_date - user_date.beginning_of_month).to_i < 10
      course.monthly_fee
    elsif (user_date.end_of_month - user_date).to_i < 10
      0
    else
      ((user_date.end_of_month - user_date).to_f / (user_date.end_of_month - user_date.beginning_of_month).to_f * course.monthly_fee).to_i
    end
  end

  def create_payments
    if course.started? && self.started?
      months = course.start_date > start_date ? months_between(course.start_date, course.end_date) : months_between(start_date, course.end_date)
      
      # First month payment
      Payment.create(:period => months.first, :amount => first_month_payment, :status => Payment::DUE, :payment_type => Payment::CREDIT, :payable_id => id, :payable_type => self.class.name)
      months[1...months.length].each do |date|
        Payment.create(:period => date, :amount => course.monthly_fee, :status => Payment::DUE, :payment_type => Payment::CREDIT, :payable_id => id, :payable_type => self.class.name)
      end

      evaluate_discount
    end
  end

  def void_payments
    payments_to_be_void = payments.due.collect { |payment| payment if payment.period.future? }.compact
    payments_to_be_void << payments.due.detect { |payment| payment if payment.period.beginning_of_month == Date.today.beginning_of_month } if (Date.today - Date.today.beginning_of_month).to_i < 10
    payments_to_be_void.each do |payment|
      payment.update_attribute(:status, Payment::VOID)
    end
  end

  def evaluate_discount
    student.evaluate_discount(session)
  end

  def apply_discount(discount)
    discountable_payments = payments.collect { |payment| payment if payment.period.future? }.compact
    discountable_payments.each do |payment|
      payment.update_attribute(:discount, discount)
    end
  end
  
  def associate_session
    StudentRegistrationFee.find_or_create_by_student_id_and_session_id(student.id, session.id)
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

  ### View Helpers ###

  def title
    "#{student.name} - #{course.title}" rescue nil
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
