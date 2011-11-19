class Payment < ActiveRecord::Base
  belongs_to :payable, :polymorphic => :true
  
  before_validation :check_payment
  
  PAID = true
  DUE = false
  
  CREDIT = true
  DEBIT = false
  
  def check_payment
    errors.add(:duplicate, "Entry already exists") if Payment.where(:period => period.beginning_of_month..period.end_of_month, :payable_id => payable_id, :payable_type => payable_type).present?
  end
  
  def paid?
    status
  end
end
