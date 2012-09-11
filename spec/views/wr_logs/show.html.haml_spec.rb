  require 'spec_helper'

  describe "wr_logs/show" do

  describe "last page" do
    before(:each) do
      @message  = { body: "yyy",
        image: "image url",
        worth_reading: "worth_reading url",
        whats_this: "what's this url",
        unsubscribe: "unsubscribe url",
        signature: "-- signature"
      }
    end

     it "renders attributes in message" do
       render
       rendered.should match(/yyy.*worth_reading%20url.*image url.*what's%20this%20url.*unsubscribe%20url.*-- signature/m)
     end
  end

  describe "more page" do
    before(:each) do
      @message  = { body: "yyy",
                    more: "more_url",
      }
    end

    it "renders attributes in message" do
      render
      rendered.should match(/yyy.*more_url/m)
    end
  end


  end
