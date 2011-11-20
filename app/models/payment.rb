class Payment < ActiveRecord::Base
  belongs_to :payable, :polymorphic => :true
  
  before_validation :check_payment
  
  PAID = true
  DUE = false
  
  CREDIT = true
  DEBIT = false
  
  scope :paid, where(:status => PAID)
  scope :due, where(:status => DUE)
  
  def check_payment
    errors.add(:duplicate, "Entry already exists") if Payment.where(:period => period.beginning_of_month..period.end_of_month, :payable_id => payable_id, :payable_type => payable_type).present?
  end
  
  def paid?
    status
  end
  
  def get_payment(month, year)
    period.month == month && period.year == year ? amount : 0
  end
end
