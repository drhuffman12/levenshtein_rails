require 'rails_helper'

RSpec.describe "Histograms", type: :request do
  describe "GET /histograms" do
    it "works! (now write some real specs)" do
      get histograms_path
      expect(response).to have_http_status(200)
    end
  end
end
