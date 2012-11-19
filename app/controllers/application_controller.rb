class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from Timeout::Error, with: :redirect_to_back

  def set_timezone
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
