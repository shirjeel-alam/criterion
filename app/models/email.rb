module Email
  def self.all_emails
    Email.admin_emails + Email.teacher_emails + Email.student_emails
  end

  def self.admin_emails
    AdminUser.emails
  end

  def self.teacher_emails
    Teacher.emails
  end

  def self.student_emails
    Student.emails
  end

  def self.staff_emails
    Staff.emails
  end

  def self.partner_emails
    Partner.emails
  end
end
