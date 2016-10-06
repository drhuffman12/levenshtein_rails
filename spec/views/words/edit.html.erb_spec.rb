require 'rails_helper'

RSpec.describe "words/edit", type: :view do
  before(:each) do
    @word = assign(:word, Word.create!(
      :name => "MyString",
      :length => 1,
      :word_length => nil,
      :histogram => nil
    ))
  end

  it "renders the edit word form" do
    render

    assert_select "form[action=?][method=?]", word_path(@word), "post" do

      assert_select "input#word_name[name=?]", "word[name]"

      assert_select "input#word_length[name=?]", "word[length]"

      assert_select "input#word_word_length_id[name=?]", "word[word_length_id]"

      assert_select "input#word_histogram_id[name=?]", "word[histogram_id]"
    end
  end
end
