class SessionsStudent < ActiveRecord::Base
	belongs_to :session
	belongs_to :student
	has_one :payment

	validates :student_id, :uniqueness => { :scope => :session_id }
  validates :student_id, :presence => true
  validates :session_id, :presence => true

  after_create :create_registration_fee

  def create_registration_fee
  	payment = Payment.create(:amount => session.registration_fee, :status => Payment::DUE, :payment_type => Payment::DEBIT, :payable_id => student_id, :payable_type => student.class.name)
  	self.update_attribute(:payment_id, payment.id)
  end
end
