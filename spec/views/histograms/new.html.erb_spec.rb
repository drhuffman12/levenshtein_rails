require 'rails_helper'

RSpec.describe "histograms/new", type: :view do
  before(:each) do
    assign(:histogram, Histogram.new(
      :hist => "{:a=>1}",
      :length => 1,
      :word_length => nil
    ))
  end

  it "renders new histogram form" do
    render

    assert_select "form[action=?][method=?]", histograms_path, "post" do

      assert_select "textarea#histogram_hist[name=?]", "histogram[hist]"

      assert_select "input#histogram_length[name=?]", "histogram[length]"

      assert_select "input#histogram_word_length_id[name=?]", "histogram[word_length_id]"
    end
  end
end
