require 'rails_helper'

RSpec.describe "words/show", type: :view do
  before(:each) do
    @word = assign(:word, Word.create!(
      :name => "Name",
      :length => 2,
      :word_length => nil,
      :histogram => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
