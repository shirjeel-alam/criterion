class Payment < ActiveRecord::Base
  belongs_to :payable, :polymorphic => :true
  
  before_validation :check_payment
  
  PAID = true
  DUE = false
  
  CREDIT = true
  DEBIT = false
  
  scope :paid, where(:status => PAID)
  scope :due, where(:status => DUE)
  scope :credit, where(:payment_type => CREDIT)
  scope :debit, where(:payment_type => DEBIT)
  
  def check_payment
    errors.add(:duplicate, "Entry already exists") if Payment.where(:period => period.beginning_of_month..period.end_of_month, :payable_id => payable_id, :payable_type => payable_type).present?
  end
  
  def paid?
    status
  end
  
  def get_payment(month, year)
    period.month == month && period.year == year ? amount : 0
  end

  def status_label
    payment.status ? 'Paid' : 'Due'
  end
      
  def type_label
    payment.payment_type ? 'Credit' : 'Debit'
  end

  def period_label
    payment.period.strftime('%B %Y')
  end
  
  def date_label
    payment.paid_on.strftime('%d-%b-%Y') rescue nil
  end
end
