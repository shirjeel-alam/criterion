class StudentRegistrationFee < ActiveRecord::Base
  belongs_to :student
  belongs_to :session
  
  DUE, PAID, VOID = 0, 1, 2

  validates :student_id, :uniqueness => { :scope => :session_id }
  
  validates :student_id, :presence => true
  validates :session_id, :presence => true
  validates :registration_fee_date, :timeliness => { :type => :date, :allow_blank => true }

  def amount
  	session.registration_fee rescue nil
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

  def pay!
    self.update_attributes(:status => PAID, :registration_fee_date => Date.today)
  end

  def void!
    self.update_attributes(:status => VOID, :registration_fee_date => Date.today)
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
end
