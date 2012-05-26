# == Schema Information
#
# Table name: students
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  email      :string(255)
#  address    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Student < ActiveRecord::Base
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :payments, through: :enrollments
  has_many :session_students
  has_many :sessions, through: :session_students
  has_many :registration_fees, through: :session_students
  has_many :phone_numbers, as: :contactable, dependent: :destroy
  has_one :admin_user, as: :user, dependent: :destroy
  has_many :received_messages, as: :receiver, class_name: 'CriterionSms'
  
  accepts_nested_attributes_for :enrollments
  accepts_nested_attributes_for :phone_numbers
  
  before_validation :set_email

  validates :name, presence: true
  validates :email, presence: true

  after_create :send_sms
  
  def enrolled_courses
    Course.active.collect { |c| c if c.has_enrollment?(self) }.compact.uniq
  end
  
  def not_enrolled_courses
    Course.active.collect { |c| c unless c.has_enrollment?(self) }.compact.uniq
  end

  def evaluate_discount(session)
    session_courses = courses.where(session_id: session.id)
    enrollment_count = session_courses.count

    discount = case enrollment_count
    when 0, 1
      nil
    when 2
      250 #500 # 250 / course
    else
      500 #900 # 300 / course
    end

    session_enrollments = enrollments.where(course_id: session_courses.collect(&:id))
    session_enrollments.each do |enrollment|
      enrollment.apply_discount(discount)
    end
  end

  def set_email
    self.email = "#{name.strip.gsub(' ', '.').downcase}@criterion.edu" unless email.present?
  end

  def send_sms
    phone_numbers.mobile.each do |phone_number|
      sms_data = { to: phone_number.number, message: "Dear Student, Your Student ID is #{id}, kindly use this ID for all future correspondence" }
      received_messages.create(sms_data)
    end
  end
 
  ### Class Methods ###

  def self.get_all
    Student.all.collect { |student| [student.name, student.id] }
  end

  def self.emails
    Student.all.collect { |student| ["#{student.name} - #{student.email}", student.email] }
  end
  
  ### View Helpers ###
  
  def address_label
    address.present? ? address : 'N/A'
  end
end
