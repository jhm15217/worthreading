class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UsersHelper
  include EmailsHelper

  # default_settings for WillPaginate
  WillPaginate.per_page = 15


end
