class MailJob
  include SuckerPunch::Job

  def perform(task, params=nil)
    case task
    when 1
      CriterionMailer.course_mail(params).deliver
    end
  end
end
