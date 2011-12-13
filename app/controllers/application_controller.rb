class ApplicationController < ActionController::Base
  protect_from_forgery

  def set_timezone
    # current_user.time_zone #=> 'London'
    Time.zone = 'Karachi'
  end
end
