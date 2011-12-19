class Payment < ActiveRecord::Base
  
  PAID, DUE = true, false
  CREDIT, DEBIT = true, false
  
  belongs_to :payable, :polymorphic => :true
  
  before_validation :check_payment, :on => :create, :if => "payable_type == 'Enrollment'"

  validates :amount, :presence => true, :numericality => { :greater_than => 0 }
  validates :status, :presence => true
  validates :payment_type, :inclusion => [CREDIT, DEBIT]
  
  scope :paid, where(:status => PAID)
  scope :due, where(:status => DUE)
  scope :credit, where(:payment_type => CREDIT)
  scope :debit, where(:payment_type => DEBIT)
  
  def check_payment
    errors.add(:duplicate, "Entry already exists") if Payment.where(:period => period.beginning_of_month..period.end_of_month, :payable_id => payable_id, :payable_type => payable_type, :payment_type => payment_type).present?
  end
  
  def paid?
    status
  end

  def +(payment)
    if payment.is_a?(Payment)
      Payment.new(:amount => (self.amount + payment.amount))
    elsif payment.is_a?(Fixnum)
      Payment.new(:amount => (self.amount + payment))
    else
      raise payment.inspect
    end
  end
  
  #TODO: Revise.. Currently not being used anywhere
  def get_payment(month, year)
    period.month == month && period.year == year ? amount : 0
  end
  
  ### Class Methods ###

  def self.statuses
    [['Paid', PAID], ['Due', DUE]]
  end

  def self.payment_types
    [['Credit', CREDIT], ['Debit', DEBIT]]
  end

  ### View Helpers ###

  def status_label
    status ? 'Paid' : 'Due'
  end
  
  def status_tag
    status ? :ok : :error
  end
      
  def type_label
    payment_type ? 'Credit' : 'Debit'
  end

  def period_label
    period.strftime('%B %Y')
  end
  
  def date_label
    paid_on.present? ? paid_on.strftime('%d-%b-%Y') : 'N/A'
  end
end
