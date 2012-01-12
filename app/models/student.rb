class Student < ActiveRecord::Base
  has_many :enrollments, :dependent => :destroy
  has_many :student_registration_fees
  has_many :courses, :through => :enrollments
  has_many :payments, :through => :enrollments
  has_many :phone_numbers, :as => :contactable, :dependent => :destroy
  
  accepts_nested_attributes_for :enrollments
  accepts_nested_attributes_for :phone_numbers
  
  before_validation :set_email

  validates :name, :presence => true
  validates :email, :presence => true
  
  def enrolled_courses
    Course.active.collect { |c| c if c.has_enrollment?(self) }.compact.uniq
  end
  
  def not_enrolled_courses
    Course.active.collect { |c| c unless c.has_enrollment?(self) }.compact.uniq
  end

  def evaluate_discount(session)
    session_courses = courses.where(:session_id => session.id)
    enrollment_count = session_courses.count

    discount = case enrollment_count
    when 0, 1
      nil
    when 2
      250 #500 # 250 / course
    else
      500 #900 # 300 / course
    end

    session_enrollments = enrollments.where(:course_id => session_courses.collect(&:id))
    session_enrollments.each do |enrollment|
      enrollment.apply_discount(discount)
    end
  end

  def set_email
    self.email = "#{name.strip.gsub(' ', '.').downcase}@criterion.com" unless email.present?
  end
 
  ### Class Methods ###

  def self.get_all
    Student.all.collect { |s| [s.name, s.id] }
  end

  #NOTE: Temp method
  def self.emails
    Student.all.collect { |s| ["#{s.name} - #{s.email}", s.email] }
  end
  
  ### View Helpers ###
  
  def address_label
    address.present? ? address : 'N/A'
  end
end
