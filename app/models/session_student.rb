# == Schema Information
#
# Table name: session_students
#
#  id         :integer(4)      not null, primary key
#  student_id :integer(4)
#  session_id :integer(4)
#  payment_id :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class SessionStudent < ActiveRecord::Base
	belongs_to :session
	belongs_to :student
	has_one :registration_fee, as: :payable, class_name: 'Payment', dependent: :destroy

	validates :student_id, uniqueness: { scope: :session_id }
  validates :student_id, presence: true
  validates :session_id, presence: true

  after_create :create_registration_fee

  def create_registration_fee
  	payment = Payment.create(amount: session.registration_fee, status: Payment::DUE, payment_type: Payment::DEBIT, payable: self)
  	self.update_attribute(:payment_id, payment.id)
  end
end
