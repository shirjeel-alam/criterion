class Payment < ActiveRecord::Base
  DUE, PAID, VOID = 0, 1, 2
  CREDIT, DEBIT = true, false
  
  belongs_to :payable, :polymorphic => :true
  
  before_validation :check_payment, :on => :create, :if => "payable_type == 'Enrollment'"

  validates :amount, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :status, :presence => true, :inclusion => { :in => [DUE, PAID, VOID] }
  validates :payment_type, :inclusion => { :in => [CREDIT, DEBIT] }
  validates :paid_on, :timeliness => { :type => :date }, :allow_blank => true
  validates :discount, :numericality => { :only_integer => true, :greater_than => 0 }, :allow_blank => true
  
  scope :paid, where(:status => PAID)
  scope :due, where(:status => DUE)
  scope :void, where(:status => VOID)
  scope :credit, where(:payment_type => CREDIT)
  scope :debit, where(:payment_type => DEBIT)
  
  def check_payment
    errors.add(:duplicate, "Entry already exists") if Payment.where(:period => period.beginning_of_month..period.end_of_month, :payable_id => payable_id, :payable_type => payable_type, :payment_type => payment_type).present?
  end
  
  def due?
    status == DUE
  end

  def paid?
    status == PAID
  end

  def void?
    status == VOID
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
  
  def net_amount
    discount.present? ? (amount - discount) : amount
  end
  
  ### Class Methods ###

  def self.statuses
    [['Due', DUE], ['Paid', PAID], ['Void', VOID]]
  end

  def self.payment_types
    [['Credit', CREDIT], ['Debit', DEBIT]]
  end

  ### View Helpers ###

  def status_label
    case status
      when DUE
        'Due'
      when PAID
        'Paid'
      when VOID
        'Void'
    end
  end
  
  def status_tag
    case status
      when DUE
        :error
      when PAID
        :ok
      when VOID
        :warning
    end
  end
      
  def type_label
    payment_type ? 'Credit' : 'Debit'
  end

  def type_tag
    payment_type ? :ok : :warning
  end

  def period_label
    period.present? ? period.strftime('%B %Y') : 'N/A'
  end
  
  def date_label
    paid_on.present? ? paid_on.strftime('%d-%b-%Y') : 'N/A'
  end
end