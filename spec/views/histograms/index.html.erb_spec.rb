require 'rails_helper'

RSpec.describe "histograms/index", type: :view do
  before(:each) do
    assign(:histograms, [
      Histogram.create!(
        :hist => "{:a=>1}",
        :length => 2,
        :word_length => nil
      ),
      Histogram.create!(
        :hist => "{:a=>1}",
        :length => 2,
        :word_length => nil
      )
    ])
  end

  it "renders a list of histograms" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
