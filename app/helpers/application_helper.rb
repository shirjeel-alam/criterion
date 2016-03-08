module ApplicationHelper
  def date_format(date, month_and_year_only = false)
    if month_and_year_only
      date.present? ? date.strftime('%B %Y') : 'N/A'
    else
      date.present? ? date.strftime('%d %B, %Y') : 'N/A'
    end
  end

  def time_format(time)
    time.present? ? time.strftime('%l:%M %p') : 'N/A'
  end

  def months_between(start_date, end_date)
    months = []
    months << start_date
    ptr = start_date >> 1
    while ptr < end_date do
      months << ptr.beginning_of_month
      ptr = ptr >> 1
    end
    months << end_date unless (start_date.beginning_of_month == end_date.beginning_of_month || months.last.beginning_of_month == end_date.beginning_of_month)
    months
  end

  def separate_name(user)
    name_separated = user.name.split(' ')
    last_name = name_separated.pop
    [name_separated.join(' '), last_name]
  end

  def days
    _days = []

    %w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday).each do |wday|
      _days << [wday, wday]
    end

    _days
  end

  def rooms
    _rooms = []

    1.upto(4) do |room_no|
      _rooms << ["Room #{room_no}", room_no]
    end

    _rooms
  end

  def status_tag(label, tag)
    content_tag(:span, label, class: "status #{tag}")
  end
end
