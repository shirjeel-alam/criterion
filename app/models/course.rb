class Course < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :session
  
  has_many :enrollments
  has_many :payments, :through => :enrollments
  has_many :students, :through => :enrollments
  
  before_save :update_status, :set_end_date
  after_save :create_payments
  
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
    case session.period
      when 0
        self.end_date = Date.parse("May #{session.year}")
      when 1
        self.end_date = Date.parse("October #{session.year}")
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
end