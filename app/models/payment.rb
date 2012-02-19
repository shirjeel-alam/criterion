class Payment < ActiveRecord::Base
  DUE, PAID, VOID, REFUNDED = 0, 1, 2, 3
  CREDIT, DEBIT = true, false
  CASH, CHEQUE = 0, 1
  
  belongs_to :payable, :polymorphic => :true
  belongs_to :category
  belongs_to :sessions_student
  
  before_validation :check_payment, :on => :create, :if => "payable_type == 'Enrollment'"

  validates :amount, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :status, :presence => true, :inclusion => { :in => [DUE, PAID, VOID, REFUNDED] }
  validates :discount, :numericality => { :only_integer => true, :greater_than => 0 }, :allow_blank => true
  validates :payment_date, :timeliness => { :type => :date, :allow_blank => true }
  validates :payment_method, :inclusion => { :in => [CASH, CHEQUE] }, :allow_blank => true
  
  scope :paid, where(:status => PAID)
  scope :due, where(:status => DUE)
  scope :void, where(:status => VOID)
  scope :refunded, where(:status => REFUNDED)
  
  scope :credit, where(:payment_type => CREDIT)
  scope :debit, where(:payment_type => DEBIT)

  scope :cash, where(:payment_method => CASH)
  scope :cheque, where(:payment_method => CHEQUE)

  scope :expenditure, where(:payable_id => nil, :payable_type => nil, :payment_type => CREDIT)

  scope :on, lambda { |date| where(:payment_date => date) }
  
  def check_payment
    errors.add(:duplicate, "Entry already exists") if Payment.where(:period => period.beginning_of_month..period.end_of_month, :payable_id => payable_id, :payable_type => payable_type, :payment_type => payment_type).present?
  end

  def session
    sessions_student.session rescue nil
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

  def refunded?
    status == REFUNDED
  end

  def credit?
    payment_type == CREDIT
  end

  def debit?
    payment_type == DEBIT
  end

  def +(payment)
    if payment.is_a?(Payment)
      Payment.new(:amount => (self.amount.to_i + payment.amount.to_i), :discount => (self.discount.to_i + payment.discount.to_i))
    elsif payment.is_a?(Fixnum)
      Payment.new(:amount => (self.amount.to_i + payment))
    else
      raise payment.inspect
    end
  end
  
  def net_amount
    discount.present? ? (amount - discount) : amount
  end

  def pay!
    self.update_attributes(:status => PAID, :payment_date => Date.today)
    create_account_entry
  end

  def void!
    self.update_attributes(:status => VOID, :payment_date => Date.today)
  end

  def refund!
    self.update_attributes(:status => REFUNDED, :payment_date => Date.today)
    create_account_entry
  end

  def create_account_entry
    if payable.is_a?(Enrollment)
      if paid?
        CriterionAccount.bank_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::DEBIT)
        CriterionAccount.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount * (1 - payable.teacher.share), :entry_type => AccountEntry::CREDIT)
        payable.teacher.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount * payable.teacher.share, :entry_type => AccountEntry::CREDIT)
      elsif refunded?
        CriterionAccount.bank_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::CREDIT)
        CriterionAccount.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount * (1 - payable.teacher.share), :entry_type => AccountEntry::DEBIT)
        payable.teacher.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount * payable.teacher.share, :entry_type => AccountEntry::DEBIT)
      end
    elsif payable.is_a?(SessionStudent)
      if paid?
        CriterionAccount.bank_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::DEBIT)
        CriterionAccount.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::CREDIT)
      elsif refunded?
        CriterionAccount.bank_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::CREDIT)
        CriterionAccount.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::DEBIT)
      end
    elsif payable.is_a?(Teacher)
      if debit?
        CriterionAccount.bank_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::DEBIT)
        payable.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::CREDIT)
      elsif credit?
        CriterionAccount.bank_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::CREDIT)
        payable.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::DEBIT)
      end
    elsif payable.is_a?(Staff)
      if debit?
        CriterionAccount.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::DEBIT)
        payable.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::CREDIT)
      elsif credit?
        CriterionAccount.bank_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::CREDIT)
        payable.criterion_account.account_entries.create!(:payment_id => self.id, :amount => net_amount, :entry_type => AccountEntry::DEBIT)
      end
    elsif payable.is_a?(Partner)
    else # Must be expenditures

    end
  end
  
  ### Class Methods ###

  def self.statuses
    [['Due', DUE], ['Paid', PAID], ['Void', VOID], ['Refunded', REFUNDED]]
  end

  def self.payment_types
    [['Credit', CREDIT], ['Debit', DEBIT]]
  end

  def self.payment_methods
    [['Cash', CASH], ['Cheque', CHEQUE]]
  end

  def self.month(date)
    date.beginning_of_month..date.end_of_month
  end

  def self.quarter(year, n)
    date = Date.new(year, 3 * n, 1)
    date.beginning_of_quarter..date.end_of_quarter
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
      when REFUNDED
        'Refunded'
    end
  end
  
  def status_tag
    case status
      when DUE
        :error
      when PAID
        :ok
      when VOID, REFUNDED
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

  def payment_method_label
    case payment_method
      when CASH
        'Cash'
      when CHEQUE
        'Cheque'
    end
  end

  def payment_method_tag
    case payment_method
      when CASH
        :ok
      when CHEQUE
        :warning
    end
  end
end
