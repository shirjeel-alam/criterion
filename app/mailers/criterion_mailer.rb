class CriterionMailer < ActionMailer::Base
  default from: "admin@criterion.edu"

  def course_mail(criterion_mail)
    @criterion_mail = criterion_mail
    to = @criterion_mail.to.split(',') rescue nil
    cc = @criterion_mail.cc.split(',') rescue nil
    bcc = @criterion_mail.bcc.split(',') rescue nil

    mail(from: @criterion_mail.from, to: to, cc: cc, bcc: bcc, subject: @criterion_mail.subject)
  end
end
