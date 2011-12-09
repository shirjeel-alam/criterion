class Student < ActiveRecord::Base
  has_many :enrollments
  has_many :student_registration_fees
  has_many :courses, :through => :enrollments
  has_many :payments, :through => :enrollments
  has_many :phone_numbers, :as => :contactable, :dependent => :destroy
  
  accepts_nested_attributes_for :enrollments
  accepts_nested_attributes_for :phone_numbers
  
  validates :name, :presence => true
  
  PAID = true
  DUE = false
  
  protected
  def self.get_students
    Student.all.collect { |s| [s.name, s.id] }
  end
end
