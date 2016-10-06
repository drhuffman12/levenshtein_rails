require 'rails_helper'

RSpec.describe "HistFriends", type: :request do
  describe "GET /hist_friends" do
    it "works! (now write some real specs)" do
      get hist_friends_path
      expect(response).to have_http_status(200)
    end
  end
end
