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
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  token_identifier :string(255)
#  emailed          :datetime
#  opened           :datetime
#  worth_reading    :datetime
#

class WrLog < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  PROD_URL = "www.worth-reading.org"
  DEV_URL = "localhost:3000"
  PROTOCOL = 'http'


  attr_accessible :action, :email_id, :email_part, :receiver_id, :responded, :sender_id
  belongs_to :email
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  before_create :create_token_identifier

  # Return a structure describing the message, indepedent of email or web page presentation
  def abstract_message
    email = Email.find(email_id)
    body = email.parts[email_part]
    if email.parts.size == email_part + 1  # is this the last part?
      if capture = body.match(/(.*)(--.*)/m)
        body = capture[1]
        signature = capture[2]
      end

      relationship = Relationship.where(subscriber_id: receiver.id,
                                        subscribed_id: sender.id).first!
      { body: body,
            image: "#{PROTOCOL}://#{PROD_URL}/assets/worth_reading_button2.png",
            worth_reading: { protocol: PROTOCOL,
                             host: (Rails.env.production? ? PROD_URL : DEV_URL),
                             id: id,
                             worth_reading: "1",
                             token_identifier: token_identifier },
            whats_this: { id: id,
                         token_identifier: token_identifier,
                         host: Rails.env.production? ? PROD_URL : DEV_URL,
                         protocol: PROTOCOL },
            unsubscribe: { id: relationship.id,
                          token_identifier: relationship.token_identifier,
                          host: Rails.env.production? ? PROD_URL : DEV_URL,
                          protocol: PROTOCOL },
            signature: signature
      }
    else
      { body: body,
            more: { more: email_part.to_s,
                    id: id,
                    token_identifier: token_identifier,
                    host: (Rails.env.production? ? PROD_URL : DEV_URL),
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
end
