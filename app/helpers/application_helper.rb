module ApplicationHelper
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

  def months_between(start_date, end_date)
    months = []
    months << start_date
    ptr = start_date >> 1
    while ptr < end_date do
      months << ptr.beginning_of_month
      ptr = ptr >> 1
    end
    months << end_date if start_date.beginning_of_month != end_date.beginning_of_month
    months      
  end
end
