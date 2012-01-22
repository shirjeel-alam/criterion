class ApplicationController < ActionController::Base
  protect_from_forgery

  def set_timezone
    # current_user.time_zone #=> 'London'
    Time.zone = 'Karachi'
  end

  def redirect_to_back(default = root_path)
    begin
      redirect_to :back
    rescue
      redirect_to default
    end
  end
end
