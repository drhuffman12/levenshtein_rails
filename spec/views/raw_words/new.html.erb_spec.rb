require 'rails_helper'

RSpec.describe "raw_words/new", type: :view do
  before(:each) do
    assign(:raw_word, RawWord.new(
      :name => "MyString",
      :is_test_case => "MyString",
      :word => nil
    ))
  end

  it "renders new raw_word form" do
    render

    assert_select "form[action=?][method=?]", raw_words_path, "post" do

      assert_select "input#raw_word_name[name=?]", "raw_word[name]"

      assert_select "input#raw_word_is_test_case[name=?]", "raw_word[is_test_case]"

      assert_select "input#raw_word_word_id[name=?]", "raw_word[word_id]"
    end
  end
end
