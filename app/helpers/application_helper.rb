module ApplicationHelper
  def link_to_remove_fields(name, f, div_to_remove)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this, \'.#{div_to_remove}\')")
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class => 'add_fields')
  end
  
  def get_students
    Student.all.collect { |s| [s.name, s.id] }
  end
  
  def get_teachers
    Teacher.all.collect { |t| [t.name, t.id] }
  end
  
  def get_courses
    Course.all.collect { |c| [course_output(c), c.id] }
  end
  
  def get_sessions
    Session.valid.collect { |s| [session_output(s), s.id] }
  end
  
  def get_session_periods
    Session.get_session_periods
  end
  
  def get_session_years
    Session.get_session_years
  end
  
  def get_phone_number_categories
    PhoneNumber.get_phone_number_categories
  end
  
  def course_output(course)
    "#{course.name} | #{course.teacher.name}"
  end
  
  def course_status_output(course)
    case course.status
      when 0
        'Not Started'
      when 1
        'In Progress'
      when 2
        'Completed'
      when 3
        'Cancelled'
    end
  end
  
  def phone_number_output(phone_number)
    "#{phone_number.number} - #{phone_number.category}"
  end
  
  def session_output(session)
    result = ""
    case session.period
      when 0
        result << 'May/June'
      when 1
        result << 'Oct/Nov'
    end
    
    result << " #{session.year}"
    result
  end
  
  def payment_status_output(payment)
    payment.status ? 'Paid' : 'Due'
  end
  
  def payment_type_output(payment)
    payment.payment_type ? 'Credit' : 'Debit'
  end
  
  def payment_period_output(payment)
    payment.period.strftime('%B %Y')
  end
end