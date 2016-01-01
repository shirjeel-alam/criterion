class SmsJob
  include SuckerPunch::Job

  def perform(task, params=nil)
    case task
    when 1
      CriterionSms.send_cumulative_fee_received_sms(params)
    when 2
      params.save
    end
  end
end