class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UsersHelper

  # default_settings for WillPaginate
  WillPaginate.per_page = 15
end
