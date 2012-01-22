class Teacher < ActiveRecord::Base
  has_many :courses
  has_many :payments, :through => :courses
  has_many :withdrawals, :as => :payable, :class_name => 'Payment', :dependent => :destroy
  has_many :phone_numbers, :as => :contactable, :dependent => :destroy
  has_many :criterion_mails, :as => :mailable
  has_one :admin_user, :as => :user, :dependent => :destroy

  before_validation :set_email
  after_create :create_admin_user

  validates :name, :presence => true
  validates :email, :presence => true
  validates :share, :presence => true, :numericality => { :greater_than => 0, :less_than_or_equal_to => 1 }

  def balance
    income = 0
    payments.credit.paid.each do |payment|
      income += payment.net_amount 
    end
    income *= share
    income - withdrawals.sum(:amount)
  end

  def set_email
    self.email = "#{name.strip.gsub(' ', '.').downcase}@criterion.edu" unless email.present?
  end

  def create_admin_user
    AdminUser.create(:email => email, :password => AdminUser::DEFAULT_PASSWORD, :role => AdminUser::TEACHER, :user => self)
  end

  ### Class Methods ###

  def self.get_all
    Teacher.all.collect { |teacher| [teacher.name, teacher.id] }
  end

  def self.emails
    Teacher.all.collect { |teacher| ["#{teacher.name} - #{teacher.email}", teacher.email] }
  end

  ### View Helpers ###

  def balance_tag
    balance >= 0 ? :ok : :error
  end
end
