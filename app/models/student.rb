class Student < ActiveRecord::Base
  has_many :enrollments, :dependent => :destroy
  has_many :student_registration_fees
  has_many :courses, :through => :enrollments
  has_many :payments, :through => :enrollments
  has_many :phone_numbers, :as => :contactable, :dependent => :destroy
  
  accepts_nested_attributes_for :enrollments
  accepts_nested_attributes_for :phone_numbers
  
  validates :name, :presence => true
  
  PAID = true
  DUE = false
 
  ### Class Methods ###

  def self.get_all
    Student.all.collect { |s| [s.name, s.id] }
  end
  
  ### View Helpers ###
  
  def address_label
    address.present? ? address : 'N/A'
  end
end
