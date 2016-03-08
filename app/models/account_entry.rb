# == Schema Information
#
# Table name: account_entries
#
#  id                   :integer          not null, primary key
#  criterion_account_id :integer
#  payment_id           :integer
#  amount               :integer
#  entry_type           :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class AccountEntry < ActiveRecord::Base
  CREDIT, DEBIT = true, false

  belongs_to :criterion_account
  belongs_to :payment

  scope :credit, where(entry_type: CREDIT)
  scope :debit, where(entry_type: DEBIT)

  scope :on, lambda { |date| where(created_at: date.beginning_of_day..date.end_of_day) }

  scope :cash, joins(:payment).where('payments.payment_method = ?', Payment::CASH)
  scope :cheque, joins(:payment).where('payments.payment_method = ?', Payment::CHEQUE)
  scope :cash_or_cheque, joins(:payment).where('payments.payment_method IN (?)', [Payment::CASH, Payment::CHEQUE])

  def credit?
    entry_type == CREDIT
  end

  def debit?
    entry_type == DEBIT
  end

  ### View Helpers ###

  def entry_type_label
    entry_type ? 'Credit' : 'Debit'
  end

  def entry_type_tag
    entry_type ? :ok : :warning
  end
end
