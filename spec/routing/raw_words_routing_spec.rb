require "rails_helper"

RSpec.describe RawWordsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/raw_words").to route_to("raw_words#index")
    end

    it "routes to #new" do
      expect(:get => "/raw_words/new").to route_to("raw_words#new")
    end

    it "routes to #show" do
      expect(:get => "/raw_words/1").to route_to("raw_words#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/raw_words/1/edit").to route_to("raw_words#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/raw_words").to route_to("raw_words#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/raw_words/1").to route_to("raw_words#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/raw_words/1").to route_to("raw_words#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/raw_words/1").to route_to("raw_words#destroy", :id => "1")
    end

  end
end
