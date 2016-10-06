require "rails_helper"

RSpec.describe HistFriendsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/hist_friends").to route_to("hist_friends#index")
    end

    it "routes to #new" do
      expect(:get => "/hist_friends/new").to route_to("hist_friends#new")
    end

    it "routes to #show" do
      expect(:get => "/hist_friends/1").to route_to("hist_friends#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/hist_friends/1/edit").to route_to("hist_friends#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/hist_friends").to route_to("hist_friends#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/hist_friends/1").to route_to("hist_friends#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/hist_friends/1").to route_to("hist_friends#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/hist_friends/1").to route_to("hist_friends#destroy", :id => "1")
    end

  end
end
