# == Schema Information
#
# Table name: payments
#
#  id              :integer          not null, primary key
#  payable_id      :integer
#  payable_type    :string(255)
#  period          :date
#  amount          :integer
#  status          :integer
#  payment_type    :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  discount        :integer
#  payment_date    :date
#  category_id     :integer
#  payment_method  :integer
#  additional_info :text
#

class Payment < ActiveRecord::Base
  DUE, PAID, VOID, REFUNDED = 0, 1, 2, 3
  CREDIT, DEBIT = true, false
  CASH, CHEQUE, INTERNAL = 0, 1, 2
  
  belongs_to :payable, polymorphic: :true
  belongs_to :category
  belongs_to :sessions_student
  has_many :account_entries, dependent: :destroy
  
  before_validation :check_payment, on: :create, if: "payable_type == 'Enrollment'"
  before_validation :check_appropriated_amount, on: :create, if: 'appropriated?'
  after_create :create_account_entry
  before_save :set_category

  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true, inclusion: { in: [DUE, PAID, VOID, REFUNDED] }
  validates :discount, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :payment_date, timeliness: { type: :date, allow_blank: true }
  validates :payment_method, inclusion: { in: [CASH, CHEQUE, INTERNAL] }, if: 'paid?'
  
  scope :paid, where(status: PAID)
  scope :due, where(status: DUE)
  scope :void, where(status: VOID)
  scope :refunded, where(status: REFUNDED)
  
  scope :credit, where(payment_type: CREDIT)
  scope :debit, where(payment_type: DEBIT)

  scope :cash, where(payment_method: CASH)
  scope :cheque, where(payment_method: CHEQUE)
  scope :internal, where(payment_method: INTERNAL)
  scope :cash_or_cheque, where(payment_method: [CASH, CHEQUE])

  scope :expenditure, where(payable_id: nil, payment_type: CREDIT, payment_method: [CASH, CHEQUE])

  scope :on, lambda { |date| where(payment_date: date) }

  scope :due_fees, lambda { |date| due.where('period <= ?', date) }

  attr_accessor :other_account
  
  def check_payment
    errors.add(:duplicate, 'Entry already exists') if Payment.where(period: period.beginning_of_month..period.end_of_month, payable_id: payable_id, payable_type: payable_type, payment_type: payment_type).present?
  end

  def check_appropriated_amount
    errors.add(:amount, 'Amount exceeds Criterion Account balance') if amount > CriterionAccount.criterion_account.balance
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

  def cash?
    payment_method == CASH
  end

  def cheque?
    payment_method == CHEQUE
  end

  def internal?
    payment_method == INTERNAL
  end

  def appropriated?
    category == Category.appropriated
  end

  def +(payment)
    if payment.is_a?(Payment)
      Payment.new(amount: (self.amount.to_i + payment.amount.to_i), discount: (self.discount.to_i + payment.discount.to_i))
    elsif payment.is_a?(Fixnum)
      Payment.new(amount: (self.amount.to_i + payment))
    else
      raise payment.inspect
    end
  end
  
  def net_amount
    discount.present? ? (amount - discount) : amount
  end

  def pay!
    self.update_attributes(status: PAID, payment_date: Date.today)
    create_account_entry
  end

  def void!
    self.update_attributes(status: VOID, payment_date: Date.today)
  end

  def refund!
    self.update_attributes(status: REFUNDED, payment_date: Date.today)
    create_account_entry
  end

  def create_account_entry
    if payable.is_a?(Enrollment)
      if paid?
        CriterionAccount.bank_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
        CriterionAccount.criterion_account.account_entries.create!(payment_id: self.id, amount: (net_amount * (1 - payable.teacher.share)).round, entry_type: AccountEntry::CREDIT)
        payable.teacher.criterion_account.account_entries.create!(payment_id: self.id, amount: (net_amount * payable.teacher.share).round, entry_type: AccountEntry::CREDIT)
      elsif refunded?
        CriterionAccount.bank_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
        CriterionAccount.criterion_account.account_entries.create!(payment_id: self.id, amount: (net_amount * (1 - payable.teacher.share)).round, entry_type: AccountEntry::DEBIT)
        payable.teacher.criterion_account.account_entries.create!(payment_id: self.id, amount: (net_amount * payable.teacher.share).round, entry_type: AccountEntry::DEBIT)
      end
    elsif payable.is_a?(SessionStudent)
      if paid?
        CriterionAccount.bank_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
        CriterionAccount.criterion_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
      elsif refunded?
        CriterionAccount.bank_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
        CriterionAccount.criterion_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
      end
    elsif payable.is_a?(Teacher) || payable.is_a?(Partner)
      if debit?
        if internal? && other_account.present?
          CriterionAccount.find(other_account).account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
        else
          CriterionAccount.bank_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
        end
        payable.criterion_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
      elsif credit?
        if internal? && other_account.present?
          CriterionAccount.find(other_account).account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
        else
          CriterionAccount.bank_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
        end
        payable.criterion_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
      end
    elsif payable.is_a?(Staff)
      if debit?
        if internal? && other_account.present?
          CriterionAccount.find(other_account).account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
        else
          CriterionAccount.criterion_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
        end
        payable.criterion_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
      elsif credit?
        if internal? && other_account.present?
          CriterionAccount.find(other_account).account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
        else
          CriterionAccount.bank_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
        end
        payable.criterion_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
      end
    elsif appropriated?
      CriterionAccount.criterion_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
      Partner.find_each do |partner|
        partner.criterion_account.account_entries.create!(payment_id: self.id, amount: (net_amount * partner.share).round, entry_type: AccountEntry::CREDIT)
      end
    else # Must be an expenditure
      if credit?
        CriterionAccount.bank_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
        CriterionAccount.criterion_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
      elsif debit?
        CriterionAccount.bank_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::DEBIT)
        CriterionAccount.criterion_account.account_entries.create!(payment_id: self.id, amount: net_amount, entry_type: AccountEntry::CREDIT)
      end
    end
  end

  # Handle when registration fee paid
  def send_fee_received_sms
    if payable.is_a?(SessionStudent)
      student = payable.student
      session = payable.session

      student.phone_numbers.mobile.each do |phone_number|
        sms_data = { to: phone_number.number, message: "Dear Student, Your payment of Rs. #{net_amount} as registration fee for #{session.label} has been received. Thank You" }
        student.received_messages.create(sms_data)
      end      
    elsif payable.is_a?(Enrollment)
      student = payable.student
      course_name = payable.course.title
      month_and_year = period_label

      student.phone_numbers.mobile.each do |phone_number|
        sms_data = { to: phone_number.number, message: "Dear Student, Your payment of Rs. #{net_amount} against #{course_name} for the period #{month_and_year} has been received. Thank You" }
        student.received_messages.create(sms_data)
      end
    end
  end
  
  ### Class Methods ###

  def self.statuses
    [['Due', DUE], ['Paid', PAID], ['Void', VOID], ['Refunded', REFUNDED]]
  end

  def self.payment_types
    [['Credit', CREDIT], ['Debit', DEBIT]]
  end

  def self.payment_methods(exclude_internal = false)
    payment_methods = [['Cash', CASH], ['Cheque', CHEQUE]]
    payment_methods << ['Internal', INTERNAL] unless exclude_internal
    payment_methods
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
      when INTERNAL
        'Internal'
    end
  end

  def payment_method_tag
    case payment_method
      when CASH
        :ok
      when CHEQUE
        :warning
      when INTERNAL
        :error
    end
  end

  def particular
    if payable.is_a?(Enrollment)
      "#{payable.student.name} (#{payable.student.id})"
    elsif payable.is_a?(SessionStudent)
      "#{payable.student.name} (#{payable.student.id}), Registration"
    elsif payable.is_a?(Teacher) || payable.is_a?(Staff) || payable.is_a?(Partner)
      "#{payable.name} (#{payable.id})"
    else # Must be an expenditure
      category.try(:name_label)
    end rescue nil
  end

  private

  def set_category
    if payable.is_a?(Enrollment)
      self.category = Category.monthly_fee
    elsif payable.is_a?(SessionStudent)
      self.category = Category.registration_fee
    end
  end
end
