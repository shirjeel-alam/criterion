# == Schema Information
#
# Table name: teachers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  share      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  partner_id :integer
#

class Teacher < ActiveRecord::Base
  has_one :admin_user, as: :user, dependent: :destroy
  has_many :courses
  has_many :enrollments, through: :courses
  has_many :payments, through: :courses
  has_many :transactions, as: :payable, class_name: 'Payment', dependent: :destroy
  has_many :phone_numbers, as: :contactable, dependent: :destroy
  has_many :criterion_mails, as: :mailable
  has_many :received_messages, as: :receiver, class_name: 'CriterionSms', dependent: :destroy
  has_many :sent_messages, as: :sender, class_name: 'CriterionSms'
  belongs_to :partner

  accepts_nested_attributes_for :phone_numbers

  before_validation :set_email
  after_create :create_admin_user
  after_save :update_admin_user_email

  validates :name, presence: true
  validates :email, presence: true
  validates :share, presence: true, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 1 }

  delegate :balance, to: :criterion_account

  # has_one :criterion_account, through: :admin_user
  def criterion_account
    admin_user.try(:criterion_account) || partner.try(:criterion_account)
  end

  def set_email
    self.email = "#{name.strip.gsub(' ', '.').downcase}@criterion.edu" unless email.present?
  end

  def create_admin_user
    AdminUser.create(email: email, password: AdminUser::DEFAULT_PASSWORD, role: AdminUser::TEACHER, user: self)
  end

  def update_admin_user_email
    admin_user.update_attribute(:email, email) if admin_user.present?
  end

  ### Class Methods ###

  def self.get_all
    Teacher.all.collect { |teacher| [teacher.name, teacher.id] }
  end

  def self.get_all_with_id
    Teacher.all.collect { |teacher| ["#{teacher.name} - #{teacher.id}", teacher.id] }
  end

  def self.emails
    Teacher.all.collect { |teacher| ["#{teacher.name} - #{teacher.email}", teacher.email] }
  end

  ### View Helpers ###

  def balance_tag
    balance >= 0 ? :ok : :error
  end
end
