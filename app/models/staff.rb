class Staff < ActiveRecord::Base
	has_many :transactions, :as => :payable, :class_name => 'Payment', :dependent => :destroy
  has_many :phone_numbers, :as => :contactable, :dependent => :destroy
  has_many :criterion_mails, :as => :mailable
  has_one :admin_user, :as => :user, :dependent => :destroy
  has_many :received_messages, :as => :receiver, :class_name => 'CriterionSms'

  accepts_nested_attributes_for :phone_numbers

  before_validation :set_email
  after_create :create_admin_user

  validates :name, :presence => true
  validates :email, :presence => true
  validates :admin_user_confirmation, :presence => true

  attr_accessor :admin_user_confirmation

  # def balance
  #   income = 0
  #   transactions.debit.each do |payment|
  #     income += payment.net_amount 
  #   end
  #   income - transactions.credit.sum(:amount)
  # end

  def set_email
    self.email = "#{name.strip.gsub(' ', '.').downcase}@criterion.edu" unless email.present?
  end

  def create_admin_user
    admin_user_attributes = { :email => email, :password => AdminUser::DEFAULT_PASSWORD, :role => AdminUser::ADMIN, :user => self }
    admin_user_attributes.merge!(:role => AdminUser::STAFF, :status => AdminUser::DEACTIVE) if admin_user_confirmation == 'false'
    AdminUser.create!(admin_user_attributes) 
  end

  def criterion_account
    admin_user.criterion_account
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