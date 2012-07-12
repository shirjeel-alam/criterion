# == Schema Information
#
# Table name: enrollments
#
#  id              :integer          not null, primary key
#  student_id      :integer
#  course_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  status          :integer
#  enrollment_date :date
#  start_date      :date
#

class Enrollment < ActiveRecord::Base  
  NOT_STARTED, IN_PROGRESS, COMPLETED, CANCELLED = 0, 1, 2, 3
  
  belongs_to :course
  belongs_to :student

  has_one :teacher, through: :course
  has_one :session, through: :course
  
  has_many :payments, as: :payable, dependent: :destroy
  
  validates :course_id, uniqueness: { scope: :student_id }
  validates :status, presence: true, inclusion: { in: [NOT_STARTED, IN_PROGRESS, COMPLETED, CANCELLED] }
  validates :start_date, timeliness: { type: :date, allow_blank: true }
  validates :enrollment_date, timeliness: { type: :date, allow_blank: true }

  before_validation :set_start_date, :set_status
  
  after_create :associate_session

  before_save :update_status
  after_save :create_payments, :evaluate_discount
  
  scope :not_started, where(status: NOT_STARTED)
  scope :in_progress, where(status: IN_PROGRESS)
  scope :completed, where(status: COMPLETED)
  scope :cancelled, where(status: CANCELLED)
  scope :started_or_completed, where(status: [IN_PROGRESS, COMPLETED])

  delegate :end_date, to: :course
  delegate :level, to: :course

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
    if course.not_started? || course.completed? || course.cancelled?
      self.status = course.status
    else
      self.start_date = start_date < course.start_date ? course.start_date : start_date
      self.status = start_date > Date.today ? NOT_STARTED : IN_PROGRESS unless completed? || cancelled?
    end
  end
  
  def first_month_payment
    user_date = course.start_date > start_date ? course.start_date : start_date

    if (user_date - user_date.beginning_of_month).to_i < 8
      course.monthly_fee
    elsif (user_date.end_of_month - user_date).to_i < 8
      0
    else
      fmp = ((user_date.end_of_month - user_date).to_f / (user_date.end_of_month - user_date.beginning_of_month).to_f * course.monthly_fee).to_i
      diff = fmp % 100
      if diff >= 50
        fmp += (fmp - diff)
      else
        fmp -= diff
      end
      fmp
    end
  end

  def create_payments
    if course.started? && self.started?
      months = course.start_date > start_date ? months_between(course.start_date, course.end_date) : months_between(start_date, course.end_date)
      
      # First month payment
      Payment.create(period: months.first, amount: first_month_payment, status: Payment::DUE, payment_type: Payment::DEBIT, payable_id: id, payable_type: self.class.name)
      months[1...months.length].each do |date|
        Payment.create(period: date, amount: course.monthly_fee, status: Payment::DUE, payment_type: Payment::DEBIT, payable_id: id, payable_type: self.class.name)
      end
    end
  end

  def void_payments
    payments_to_be_void = payments.due.collect { |payment| payment if payment.period.future? && payment.due? }.compact
    payments_to_be_void << payments.due.detect { |payment| payment if payment.period.beginning_of_month == Date.today.beginning_of_month && (Date.today - Date.today.beginning_of_month).to_i < 8 }
    payments_to_be_void = payments_to_be_void.compact
    payments_to_be_void.each do |payment|
      payment.void!
    end
  end

  def evaluate_discount
    student.evaluate_discount(session)
  end

  def apply_discount(discount)
    discountable_payments = payments.collect { |payment| payment if payment.period.future? && payment.due? }.compact
    discountable_payments << payments.due.detect { |payment| payment if payment.period.beginning_of_month == Date.today.beginning_of_month && (Date.today - Date.today.beginning_of_month).to_i < 8 }
    discountable_payments = discountable_payments.compact
    discountable_payments.each do |payment|
      payment.update_attribute(:discount, discount)
    end
  end
  
  def associate_session
    SessionStudent.find_or_create_by_student_id_and_session_id(student.id, session.id)
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
    months << end_date unless (start_date.beginning_of_month == end_date.beginning_of_month || months.last.beginning_of_month == end_date.beginning_of_month)
    months      
  end

  def start!
    self.update_attributes(status: IN_PROGRESS, enrollment_date: Date.today, start_date: Date.today)
  end

  def complete!
    self.update_attributes(status: COMPLETED, enrollment_date: Date.today)
  end

  def cancel!
    self.update_attributes(status: CANCELLED, enrollment_date: Date.today)
    void_payments
  end

  def update_enrollment
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

  def payment(month)
    payments.where(period: month.beginning_of_month..month.end_of_month).first
  end

  def session_id
    course.session.id
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
