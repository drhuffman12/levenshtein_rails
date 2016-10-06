require "rails_helper"

RSpec.describe WordFriendsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/word_friends").to route_to("word_friends#index")
    end

    it "routes to #new" do
      expect(:get => "/word_friends/new").to route_to("word_friends#new")
    end

    it "routes to #show" do
      expect(:get => "/word_friends/1").to route_to("word_friends#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/word_friends/1/edit").to route_to("word_friends#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/word_friends").to route_to("word_friends#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/word_friends/1").to route_to("word_friends#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/word_friends/1").to route_to("word_friends#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/word_friends/1").to route_to("word_friends#destroy", :id => "1")
    end

  end
end
