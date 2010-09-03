# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  filter_parameter_logging :password
  include ExceptionNotifiable
  # uncomment the next line to test Exception Notification from localhost
  # local_addresses.clear
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_ftp_session_id'
  before_filter :set_cookie
  
  def set_cookie
    cookies[:BALANCEID] = 'balancer.mongrel0'
    #cookies[:BALANCEID] = 'balancer.mongrel'+(Time.now.sec % 4).to_s if !cookies[:BALANCEID]
    return true
  end
end
