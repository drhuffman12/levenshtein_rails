require 'rails_helper'

RSpec.describe "word_lengths/show", type: :view do
  before(:each) do
    @word_length = assign(:word_length, WordLength.create!(
      :length => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
  end
end
