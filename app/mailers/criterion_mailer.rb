class CriterionMailer < ActionMailer::Base
  default from: "admin@criterion.com"

  def course_mail(mail)
    @mail = mail

    mail(:from => @mail.from, :to => @mail.to, :cc => @mail.cc, :bcc => @mail.bcc, :subject => @mail.subject)
  end
end
