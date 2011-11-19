class Enrollment < ActiveRecord::Base
  belongs_to :course
  belongs_to :student
  has_many :payments, :as => :payable, :dependent => :destroy
  
  validates :student_id, :presence => true
  validates :course_id, :presence => true
  
  def create_payments
    months = months_between(course.start_date, course.end_date)
    
    # First month payment
    Payment.create(:period => months.first, :amount => course.first_month_payment, :status => Payment::DUE, :payment_type => Payment::CREDIT, :payable_id => id, :payable_type => self.class.name)
    months[1..(months.length - 1)].each do |date|
      Payment.create(:period => date, :amount => course.monthly_fee, :status => Payment::DUE, :payment_type => Payment::CREDIT, :payable_id => id, :payable_type => self.class.name)
    end
  end
  
  private
  def months_between(start_date, end_date)
    months = []
    months << start_date
    ptr = start_date >> 1
    while ptr < end_date do
      months << ptr.beginning_of_month
      ptr = ptr >> 1
    end
    months << end_date
    months      
  end

end
