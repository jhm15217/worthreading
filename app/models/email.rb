class Email < ActiveRecord::Base
  attr_accessible :body, :from, :subject, :to
end
