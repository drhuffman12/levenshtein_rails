require 'rails_helper'

RSpec.describe "word_lengths/index", type: :view do
  before(:each) do
    assign(:word_lengths, [
      WordLength.create!(
        :length => 2
      ),
      WordLength.create!(
        :length => 2
      )
    ])
  end

  it "renders a list of word_lengths" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
