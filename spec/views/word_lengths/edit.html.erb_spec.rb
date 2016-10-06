require 'rails_helper'

RSpec.describe "word_lengths/edit", type: :view do
  before(:each) do
    @word_length = assign(:word_length, WordLength.create!(
      :length => 1
    ))
  end

  it "renders the edit word_length form" do
    render

    assert_select "form[action=?][method=?]", word_length_path(@word_length), "post" do

      assert_select "input#word_length_length[name=?]", "word_length[length]"
    end
  end
end
