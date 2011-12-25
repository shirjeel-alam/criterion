class Teacher < ActiveRecord::Base
  has_many :courses
  has_many :payments, :through => :courses
  has_many :withdrawals, :as => :payable, :class_name => 'Payment', :dependent => :destroy
  has_many :phone_numbers, :as => :contactable, :dependent => :destroy

  validates :name, :presence => true
  validates :share, :presence => true, :numericality => { :greater_than => 0, :less_than_or_equal_to => 1 }

  def balance
  	(payments.credit.paid.sum(:amount) * share) - withdrawals.sum(:amount) 
  end

  ### Class Methods ###

  def self.get_all
    Teacher.all.collect { |teacher| [teacher.name, teacher.id] }
  end
end
