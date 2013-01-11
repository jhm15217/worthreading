# == Schema Information
#
# Table name: wr_logs
#
#  id               :integer         not null, primary key
#  action           :string(255)
#  sender_id        :integer
#  receiver_id      :integer
#  email_id         :integer
#  email_part       :integer
#  url              :string
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  token_identifier :string(255)
#  emailed          :datetime
#  opened           :datetime
#  followed_url     :datetime
#  forwarded        :datetime
#

class WrLog < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  PROD_URL = "www.worth-reading.org"
  DEV_URL = "localhost:3000"
  PROTOCOL = 'http'


  attr_accessible :action, :email_id, :email_part, :receiver_id, :sender_id, :url
  belongs_to :email
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  before_create :create_token_identifier

  URL_REGEX = '(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+' +
              '|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:\'".,<>?]))'
     # Courtesy of http://daringfireball.net/2010/07/improved_regex_for_matching_urls

  SERVER_URL = Rails.env.production? ? PROD_URL : DEV_URL

  # Return a structure describing the message, independent of email or web page presentation
  def abstract_message
    email = Email.find(email_id)
    body = email.parts[email_part]
    if !self.url and match = body.match(URL_REGEX)
      self.url = match.captures[0]
      body.sub!(self.url, "<a href=\"http://#{SERVER_URL}/wr_logs/#{id}/follow/#{token_identifier}\">#{self.url}</a>")
      update
    end

    if email.parts.size == email_part + 1  # is this the last part?

      relationship = Relationship.where(subscriber_id: receiver.id,
                                        subscribed_id: sender.id).first!
      { body: body,
            forward: { protocol: PROTOCOL,
                             host: SERVER_URL,
                             id: id,
                             forward: "1",
                             token_identifier: token_identifier },
            whats_this: { id: id,
                         token_identifier: token_identifier,
                         host: SERVER_URL,
                         protocol: PROTOCOL },
            unsubscribe: { id: relationship.id,
                          token_identifier: relationship.token_identifier,
                          host: SERVER_URL,
                          protocol: PROTOCOL }
      }
    else
      { body: body,
            more: { more: email_part.to_s,
                    id: id,
                    token_identifier: token_identifier,
                    host: SERVER_URL,
                    protocol: PROTOCOL}
      }
    end
  end

  private
  def create_token_identifier
    self.token_identifier = SecureRandom.urlsafe_base64
  end
  # Validataions
  validates :sender_id, presence: true
  validates :email_id, presence:   true
  validates :receiver_id, presence:   true
  validates :email_part, presence:   true
end
