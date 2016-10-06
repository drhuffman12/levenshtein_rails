require 'rails_helper'

RSpec.describe "WordFriends", type: :request do
  describe "GET /word_friends" do
    it "works! (now write some real specs)" do
      get word_friends_path
      expect(response).to have_http_status(200)
    end
  end
end
