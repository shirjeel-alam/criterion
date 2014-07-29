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
  has_one :admin_user, as: :user, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :payments, through: :enrollments
  has_many :session_students, dependent: :destroy
  has_many :sessions, through: :session_students
  has_many :registration_fees, through: :session_students
  has_many :phone_numbers, as: :contactable, dependent: :destroy
  has_many :received_messages, as: :receiver, class_name: 'CriterionSms', dependent: :destroy
  
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
    session_enrollments = enrollments.in_progress.where(course_id: session.courses.collect(&:id))
    
    same_level_enrollments = session_enrollments.group_by(&:level)
    same_level_enrollments.each do |same_level_enrollment|
      give_discount = same_level_enrollment.second.count > 1

      if give_discount
        same_level_enrollment.second.each do |enrollment|
          enrollment.apply_discount(250) unless enrollment.discount_applied
          session_enrollments - [enrollment]
        end
      end
    end

    same_teacher_enrollments = session_enrollments.group_by(&:teacher)
    same_teacher_enrollments.each do |same_teacher_enrollment|
      levels = same_teacher_enrollment.second.collect(&:level)
      if levels.count > 1 && levels.include?(Course::AS_LEVEL) && levels.include?(Course::A2_LEVEL)
        same_teacher_enrollment.second.detect { |enrollment| enrollment.course.level == Course::AS_LEVEL && !enrollment.discount_applied }.apply_discount(250) rescue nil
        same_teacher_enrollment.second.detect { |enrollment| enrollment.course.level == Course::A2_LEVEL && !enrollment.discount_applied }.apply_discount(250) rescue nil
      end
    end
  end

  def send_sms
    phone_numbers.mobile.each do |phone_number|
      sms_data = { to: phone_number.number, message: "Dear Student, Thank You for registering with Criterion Educational Institute. Your Student ID is #{id}, kindly use this ID for all future correspondence." }
      received_messages.create(sms_data) rescue false 
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
