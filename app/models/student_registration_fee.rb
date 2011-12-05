class StudentRegistrationFee < ActiveRecord::Base
  belongs_to :student
  belongs_to :session
  
  validates :student_id, :uniqueness => { :scope => :session_id }
  
  validates :student_id, :presence => true
  validates :session_id, :presence => true
end
