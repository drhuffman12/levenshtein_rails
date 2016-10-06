require 'rails_helper'

RSpec.describe "WordLengths", type: :request do
  describe "GET /word_lengths" do
    it "works! (now write some real specs)" do
      get word_lengths_path
      expect(response).to have_http_status(200)
    end
  end
end
