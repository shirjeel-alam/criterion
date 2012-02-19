class Partner < ActiveRecord::Base
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
  validates :share, :presence => true, :numericality => { :greater_than_or_equal_to => 0.1, :less_than_or_equal_to => 1 }

  def set_email
    self.email = "#{name.strip.gsub(' ', '.').downcase}@criterion.edu" unless email.present?
  end

  def create_admin_user
    AdminUser.create(:email => email, :password => AdminUser::DEFAULT_PASSWORD, :role => AdminUser::SUPER_ADMIN, :user => self)
  end

  def criterion_account
    admin_user.criterion_account
  end

  ### Class Methods ###

  def self.get_all
    Partner.all.collect { |partner| [partner.name, partner.id] }
  end

  def self.emails
    Partner.all.collect { |partner| ["#{partner.name} - #{partner.email}", partner.email] }
  end
end
