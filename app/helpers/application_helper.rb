module ApplicationHelper
  def link_to_remove_fields(name, f, div_to_remove)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this, \'.#{div_to_remove}\')")
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", class: 'add_fields')
  end
  
  def date_format(date, month_and_year_only = false)
    if month_and_year_only
      date.present? ? date.strftime('%B %Y') : 'N/A'
    else
      date.present? ? date.strftime('%d %B, %Y') : 'N/A'
    end
  end

  def time_format(time)
    time.present? ? time.strftime('%l:%M %P') : 'N/A'
  end
end
