require 'rails_helper'

RSpec.describe "hist_friends/new", type: :view do
  before(:each) do
    assign(:hist_friend, HistFriend.new(
      :hist_from => nil,
      :hist_to => nil,
      :traced_by => nil,
      :traced_last_by => nil
    ))
  end

  it "renders new hist_friend form" do
    render

    assert_select "form[action=?][method=?]", hist_friends_path, "post" do

      assert_select "input#hist_friend_hist_from_id[name=?]", "hist_friend[hist_from_id]"

      assert_select "input#hist_friend_hist_to_id[name=?]", "hist_friend[hist_to_id]"

      assert_select "textarea#hist_friend_traced_by[name=?]", "hist_friend[traced_by]"

      assert_select "input#hist_friend_traced_last_by[name=?]", "hist_friend[traced_last_by]"
    end
  end
end
