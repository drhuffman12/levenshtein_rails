require 'rails_helper'

RSpec.describe "raw_words/index", type: :view do
  before(:each) do
    assign(:raw_words, [
      RawWord.create!(
        :name => "Name",
        :is_test_case => "Is Test Case",
        :word => nil
      ),
      RawWord.create!(
        :name => "Name",
        :is_test_case => "Is Test Case",
        :word => nil
      )
    ])
  end

  it "renders a list of raw_words" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Is Test Case".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
