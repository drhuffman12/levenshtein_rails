require 'rails_helper'

RSpec.describe "word_friends/show", type: :view do
  before(:each) do
    @word_friend = assign(:word_friend, WordFriend.create!(
      :word_from => nil,
      :word_to => nil,
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
