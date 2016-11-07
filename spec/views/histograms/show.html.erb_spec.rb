require 'rails_helper'

RSpec.describe "histograms/show", type: :view do
  before(:each) do
    @histogram = assign(:histogram, Histogram.create!(
      :hist => "{:a=>1}",
      :length => 2,
      :word_length => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
  end
end
