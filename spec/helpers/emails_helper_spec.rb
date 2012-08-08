require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the EmailsHelper. For example:
#
describe EmailsHelper do
  describe "email_address_parts" do
    it "handles unquoted names" do
      email_address_parts("Jim<jim@email.com>") == { name: "Jim", email: "jim@email.com" }
    end
    it "handles quoted names" do
      email_address_parts('"Jim Jones"<jim@email.com>') == { name: "Jim Jones", email: "jim@email.com" }
    end
    it "handles no name" do
      email_address_parts("jim@email.com") == { name: "", email: "jim@email.com" }
    end
    it "handles error" do
      email_address_parts("Jim<jimemail.com>") == nil
    end
  end

  describe "email_address_list" do
    it "handles singleton" do
      email_address_list("Jim<jim@email.com>") == []
    end
    it "handles two names" do
      email_address_list('"Jim Jones"<jim@email.com>,Jim<jim@email.com>') == [{ name: "Jim Jones", email: "jim@email.com" },{ name: "Jim", email: "jim@email.com" }]
    end
    it "handles error" do
      email_address_list("Jim<jimemail.com>") == []
    end
  end
end