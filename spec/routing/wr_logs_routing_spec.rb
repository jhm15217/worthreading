require "spec_helper"

describe WrLogsController do
  describe "routing" do

    it "routes to #index" do
      get("/wr_logs").should route_to("wr_logs#index")
    end

    it "routes to #new" do
      get("/wr_logs/new").should route_to("wr_logs#new")
    end

    it "routes to #show" do
      get("/wr_logs/1").should route_to("wr_logs#show", :id => "1")
    end

    it "routes to #edit" do
      get("/wr_logs/1/edit").should route_to("wr_logs#edit", :id => "1")
    end

    it "routes to #create" do
      post("/wr_logs").should route_to("wr_logs#create")
    end

    it "routes to #update" do
      put("/wr_logs/1").should route_to("wr_logs#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/wr_logs/1").should route_to("wr_logs#destroy", :id => "1")
    end

  end
end
