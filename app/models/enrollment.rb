class Enrollment < ActiveRecord::Base
  belongs_to :course
  belongs_to :student
  
  has_many :payments, :as => :payable, :dependent => :destroy
  
  validates :course_id, :presence => true
  validates :course_id, :uniqueness => { :scope => :student_id }
  
  after_save :create_payments
  after_create :associate_session
  
  def create_payments
    if course.started?
      months = course.start_date < created_at.to_date ? months_between(created_at.to_date, course.end_date) : months_between(course.start_date, course.end_date)
      
      # First month payment
      Payment.create(:period => months.first, :amount => course.first_month_payment, :status => Payment::DUE, :payment_type => Payment::CREDIT, :payable_id => id, :payable_type => self.class.name)
      months[1..(months.length - 1)].each do |date|
        Payment.create(:period => date, :amount => course.monthly_fee, :status => Payment::DUE, :payment_type => Payment::CREDIT, :payable_id => id, :payable_type => self.class.name)
      end
    end
  end
  
  def associate_session
    StudentRegistrationFee.create(:student => student, :session => course.session)
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
end