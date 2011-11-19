class Student < ActiveRecord::Base
  has_many :enrollments
  has_many :courses, :through => :enrollments
  has_many :payments, :through => :enrollments
  has_many :phone_numbers, :as => :contactable, :dependent => :destroy
  
  accepts_nested_attributes_for :enrollments
  accepts_nested_attributes_for :phone_numbers
  
  PAID = true
  DUE = false
end
