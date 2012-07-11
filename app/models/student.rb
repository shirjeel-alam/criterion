# == Schema Information
#
# Table name: students
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  address    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Student < ActiveRecord::Base
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :payments, through: :enrollments
  has_many :session_students, dependent: :destroy
  has_many :sessions, through: :session_students
  has_many :registration_fees, through: :session_students
  has_many :phone_numbers, as: :contactable, dependent: :destroy
  has_one :admin_user, as: :user, dependent: :destroy
  has_many :received_messages, as: :receiver, class_name: 'CriterionSms'
  
  accepts_nested_attributes_for :enrollments
  accepts_nested_attributes_for :phone_numbers
  
  before_validation :check_mobile_number
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
    # Handles cases for enrollments on same level i.e. O-Level, AS-Level, A-Level
    session_courses = courses.where(session_id: session.id).group_by(&:level)
    session_courses.each do |session_course|
      discount = case session_course.second.count
      when 0, 1
        nil
      when 2
        250
      else
        500
      end

      session_enrollments = enrollments.where(course_id: session_course.second.collect(&:id))
      session_enrollments.map { |enrollment| enrollment.apply_discount(discount) }
    end
  end

  def send_sms
    phone_numbers.mobile.each do |phone_number|
      sms_data = { to: phone_number.number, message: "Dear Student, Thank You for registering with Criterion Educational Institute. Your Student ID is #{id}, kindly use this ID for all future correspondence." }
      received_messages.create(sms_data)
    end
  end
 
  ### Class Methods ###

  def self.get_all
    Student.all.collect { |student| [student.name, student.id] }
  end

  def self.get_all_with_id
    Student.all.collect { |student| ["#{student.name} - #{student.id}", student.id] }
  end

  def self.emails
    Student.all.collect { |student| ["#{student.name} - #{student.email}", student.email] }
  end
  
  ### View Helpers ###
  
  def address_label
    address.present? ? address : 'N/A'
  end

  private

  def set_email
    self.email = "#{name.strip.gsub(' ', '.').downcase}@criterion.edu" unless email.present?
  end

  def check_mobile_number
    errors.add(:base, 'Please add a mobile number') if phone_numbers.blank?
  end
end
