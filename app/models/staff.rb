# == Schema Information
#
# Table name: staffs
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Staff < ActiveRecord::Base
  has_one :admin_user, as: :user, dependent: :destroy
  has_one :criterion_account, through: :admin_user
	has_many :transactions, as: :payable, class_name: 'Payment', dependent: :destroy
  has_many :phone_numbers, as: :contactable, dependent: :destroy
  has_many :criterion_mails, as: :mailable
  has_many :received_messages, as: :receiver, class_name: 'CriterionSms', dependent: :destroy
  has_many :sent_messages, as: :sender, class_name: 'CriterionSms'

  accepts_nested_attributes_for :phone_numbers

  before_validation :set_email
  after_create :create_admin_user
  after_save :update_admin_user_email

  validates :name, presence: true
  validates :email, presence: true
  validates :admin_user_confirmation, presence: true

  attr_accessor :admin_user_confirmation

  delegate :balance, to: :criterion_account

  def set_email
    self.email = "#{name.strip.gsub(' ', '.').downcase}@criterion.edu" unless email.present?
  end

  def create_admin_user
    admin_user_attributes = { email: email, password: AdminUser::DEFAULT_PASSWORD, role: AdminUser::ADMIN, user: self }
    admin_user_attributes.merge!(role: AdminUser::STAFF, status: AdminUser::DEACTIVE) if admin_user_confirmation == 'false'
    AdminUser.create!(admin_user_attributes) 
  end

  def update_admin_user_email
    admin_user.update_attribute(:email, email) if admin_user.present?
  end

  ### Class Methods ###

  def self.get_all
    Staff.all.collect { |staff| [staff.name, staff.id] }
  end

  def self.emails
    Staff.all.collect { |staff| ["#{staff.name} - #{staff.email}", staff.email] }
  end

  ### View Helpers ###

  def balance_tag
    balance >= 0 ? :ok : :error
  end
end
