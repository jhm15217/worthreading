class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UsersHelper
  include EmailsHelper
  include WrLogsHelper

  # default_settings for WillPaginate
  WillPaginate.per_page = 15
  
end
