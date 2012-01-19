class CriterionMailer < ActionMailer::Base
  default from: "admin@criterion.edu"

  def course_mail(criterion_mail)
    @criterion_mail = criterion_mail

    mail(:from => @criterion_mail.from, :to => @criterion_mail.to.split(','), :cc => @criterion_mail.cc.split(','), :bcc => @criterion_mail.bcc.split(','), :subject => @criterion_mail.subject)
  end
end
