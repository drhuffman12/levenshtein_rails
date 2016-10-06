require "rails_helper"

RSpec.describe WordLengthsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/word_lengths").to route_to("word_lengths#index")
    end

    it "routes to #new" do
      expect(:get => "/word_lengths/new").to route_to("word_lengths#new")
    end

    it "routes to #show" do
      expect(:get => "/word_lengths/1").to route_to("word_lengths#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/word_lengths/1/edit").to route_to("word_lengths#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/word_lengths").to route_to("word_lengths#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/word_lengths/1").to route_to("word_lengths#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/word_lengths/1").to route_to("word_lengths#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/word_lengths/1").to route_to("word_lengths#destroy", :id => "1")
    end

  end
end
