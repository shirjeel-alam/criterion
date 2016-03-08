# == Schema Information
#
# Table name: phone_numbers
#
#  id               :integer          not null, primary key
#  number           :string(255)
#  category         :integer
#  contactable_id   :integer
#  contactable_type :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  belongs_to       :integer
#

class PhoneNumber < ActiveRecord::Base
  MOBILE, LANDLINE = 0, 1
  STUDENT, FATHER, MOTHER = 0, 1, 2

  belongs_to :contactable, polymorphic: true

  before_validation :strip_number

  validates :number, presence: true, uniqueness: true, numericality: true
  validates :number, format: { with: /^03\d{9}$/ }, if: :mobile?
  validates :category, presence: true, inclusion: { in: [MOBILE, LANDLINE] }
  validates :belongs_to, presence: true, inclusion: { in: [STUDENT, FATHER, MOTHER] }

  scope :mobile, where(category: MOBILE)

  def mobile?
    category == MOBILE
  end

  def landline?
    category == LANDLINE
  end

  def sent_sms
    CriterionSms.where(to: number)
  end

  ### Class Methods ###

  def self.categories
    [['Mobile', MOBILE], ['Landline', LANDLINE]]
  end

  def self.belongs_to
    [['Student', STUDENT], ['Father', FATHER], ['Mother', MOTHER]]
  end

  def self.all_mobile_numbers
    PhoneNumber.mobile.collect { |phone_number| ["#{phone_number.contactable.name + ' -' rescue nil} #{phone_number.number}".lstrip, phone_number.number] }
  end

  ### View Helpers ###

  def label
    "#{number} - #{belongs_to_label} (#{category_label})"
  end

  def category_label
    case category
    when MOBILE
      'Mobile'
    when LANDLINE
      'Landline'
    end
  end

  def belongs_to_label
    case belongs_to
    when STUDENT
      'Student'
    when FATHER
      'Father'
    when MOTHER
      'Mother'
    end
  end

  private
  def strip_number
    self.number = number.strip
  end
end
