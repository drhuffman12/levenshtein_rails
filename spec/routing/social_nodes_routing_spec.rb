require "rails_helper"

RSpec.describe SocialNodesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/social_nodes").to route_to("social_nodes#index")
    end

    it "routes to #new" do
      expect(:get => "/social_nodes/new").to route_to("social_nodes#new")
    end

    it "routes to #show" do
      expect(:get => "/social_nodes/1").to route_to("social_nodes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/social_nodes/1/edit").to route_to("social_nodes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/social_nodes").to route_to("social_nodes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/social_nodes/1").to route_to("social_nodes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/social_nodes/1").to route_to("social_nodes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/social_nodes/1").to route_to("social_nodes#destroy", :id => "1")
    end

  end
end
