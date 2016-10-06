require "rails_helper"

RSpec.describe HistogramsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/histograms").to route_to("histograms#index")
    end

    it "routes to #new" do
      expect(:get => "/histograms/new").to route_to("histograms#new")
    end

    it "routes to #show" do
      expect(:get => "/histograms/1").to route_to("histograms#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/histograms/1/edit").to route_to("histograms#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/histograms").to route_to("histograms#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/histograms/1").to route_to("histograms#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/histograms/1").to route_to("histograms#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/histograms/1").to route_to("histograms#destroy", :id => "1")
    end

  end
end
