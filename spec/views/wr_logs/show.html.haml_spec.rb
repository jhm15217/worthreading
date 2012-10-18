  require 'spec_helper'

  describe "wr_logs/show" do

  describe "last page" do
    before(:each) do
      @message  = { body: "yyy",
        image: "image url",
        forward: "forward url",
        whats_this: "what's this url",
        unsubscribe: "unsubscribe url",
      }
    end

     it "renders attributes in message" do
       render
       rendered.should match(/yyy.*forward%20url.*unsubscribe%20url/m)
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
