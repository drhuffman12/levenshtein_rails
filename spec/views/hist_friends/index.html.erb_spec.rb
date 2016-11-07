require 'rails_helper'

RSpec.describe "hist_friends/index", type: :view do
  before(:each) do
    assign(:hist_friends, [
      HistFriend.create!(
        :hist_from => nil,
        :hist_to => nil,
        :traced_by => nil,
        :traced_last_by => "Traced Last By"
      ),
      HistFriend.create!(
        :hist_from => nil,
        :hist_to => nil,
        :traced_by => nil,
        :traced_last_by => "Traced Last By"
      )
    ])
  end

  it "renders a list of hist_friends" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Traced Last By".to_s, :count => 2
  end
end
