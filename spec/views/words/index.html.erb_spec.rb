require 'rails_helper'

RSpec.describe "words/index", type: :view do
  before(:each) do
    assign(:words, [
      Word.create!(
        :name => "Name",
        :length => 2,
        :word_length => nil,
        :histogram => nil
      ),
      Word.create!(
        :name => "Name",
        :length => 2,
        :word_length => nil,
        :histogram => nil
      )
    ])
  end

  it "renders a list of words" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
