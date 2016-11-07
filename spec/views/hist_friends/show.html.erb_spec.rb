require 'rails_helper'

RSpec.describe "hist_friends/show", type: :view do
  before(:each) do
    @hist_friend = assign(:hist_friend, HistFriend.create!(
      :hist_from => nil,
      :hist_to => nil,
      :traced_by => nil,
      :traced_last_by => "Traced Last By"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Traced Last By/)
  end
end
