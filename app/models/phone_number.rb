# == Schema Information
#
# Table name: phone_numbers
#
#  id               :integer(4)      not null, primary key
#  number           :string(255)
#  category         :integer(4)
#  contactable_id   :integer(4)
#  contactable_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class PhoneNumber < ActiveRecord::Base
  MOBILE, HOME, WORK, GENERAL = 0, 1, 2, 3

  belongs_to :contactable, :polymorphic => true

  before_validation :strip_number

  validates :number, :presence => true, :uniqueness => true, :numericality => true
  validates :number, :format => { :with => /^03\d{9}$/ }, :if => :mobile?
  validates :category, :presence => true, :inclusion => { :in => [MOBILE, HOME, WORK, GENERAL] }

  scope :mobile, where(:category => MOBILE)
  scope :home, where(:category => HOME)
  scope :work, where(:category => WORK)
  scope :general, where(:category => GENERAL)

  def mobile?
    category == MOBILE
  end

  def home?
    category == HOME
  end

  def work?
    category == WORK
  end

  def general?
    category == GENERAL
  end

  def sent_sms
    CriterionSms.where(to: number)
  end

  ### Class Methods ###

  def self.categories
    [['Mobile', MOBILE], ['Home', HOME], ['Work', WORK], ['General', GENERAL]]
  end

  def self.all_mobile_numbers
    PhoneNumber.mobile.collect { |phone_number| ["#{phone_number.contactable.name + ' -' rescue nil} #{phone_number.number}".lstrip, phone_number.number] }
  end

  def self.valid_mobile_number?(number)
    number.match(/^03\d{9}$/).present?
  end

  ### View Helpers ###

  def label
    "#{number} - #{category_label}"
  end
  
  def category_label
    case category
    when MOBILE
      'Mobile'
    when HOME
      'Home'
    when WORK
      'Work'
    when GENERAL
      'General'
    end
  end

  private
  def strip_number
    self.number = number.strip
  end
end