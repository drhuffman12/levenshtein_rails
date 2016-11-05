require 'rails_helper'

RSpec.describe "RawWords", type: :request do
  describe "GET /raw_words" do
    it "works! (now write some real specs)" do
      get raw_words_path
      expect(response).to have_http_status(200)
    end
  end
end
