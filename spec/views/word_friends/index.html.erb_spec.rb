require 'rails_helper'

RSpec.describe "word_friends/index", type: :view do
  before(:each) do
    assign(:word_friends, [
      WordFriend.create!(
        :word_from => nil,
        :word_to => nil,
        :traced_by => nil,
        :traced_last_by => "Traced Last By"
      ),
      WordFriend.create!(
        :word_from => nil,
        :word_to => nil,
        :traced_by => nil,
        :traced_last_by => "Traced Last By"
      )
    ])
  end

  it "renders a list of word_friends" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Traced Last By".to_s, :count => 2
  end
end
