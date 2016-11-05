require 'rails_helper'

RSpec.describe "raw_words/show", type: :view do
  before(:each) do
    @raw_word = assign(:raw_word, RawWord.create!(
      :name => "Name",
      :is_test_case => "Is Test Case",
      :word => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Is Test Case/)
    expect(rendered).to match(//)
  end
end
