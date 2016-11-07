require 'rails_helper'

RSpec.describe "word_friends/edit", type: :view do
  before(:each) do
    @word_friend = assign(:word_friend, WordFriend.create!(
      :word_from => nil,
      :word_to => nil,
      :traced_by => nil,
      :traced_last_by => nil
    ))
  end

  it "renders the edit word_friend form" do
    render

    assert_select "form[action=?][method=?]", word_friend_path(@word_friend), "post" do

      assert_select "input#word_friend_word_from_id[name=?]", "word_friend[word_from_id]"

      assert_select "input#word_friend_word_to_id[name=?]", "word_friend[word_to_id]"

      assert_select "textarea#word_friend_traced_by[name=?]", "word_friend[traced_by]"

      assert_select "input#word_friend_traced_last_by[name=?]", "word_friend[traced_last_by]"
    end
  end
end
