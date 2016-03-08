class SmsJob
  include SuckerPunch::Job

  def perform(task, params=nil)
    case task
    when 1
      CriterionSms.send_cumulative_fee_received_sms(params)
    when 2
      params.save
    when 3
      params.send_sms
    end
  end

  def later(sec, task, params=nil)
    after(sec) { perform(task, params) }
  end
end
