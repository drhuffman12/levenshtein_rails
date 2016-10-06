require 'rails_helper'

RSpec.describe "word_lengths/new", type: :view do
  before(:each) do
    assign(:word_length, WordLength.new(
      :length => 1
    ))
  end

  it "renders new word_length form" do
    render

    assert_select "form[action=?][method=?]", word_lengths_path, "post" do

      assert_select "input#word_length_length[name=?]", "word_length[length]"
    end
  end
end
