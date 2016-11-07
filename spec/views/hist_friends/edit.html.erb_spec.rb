require 'rails_helper'

RSpec.describe "hist_friends/edit", type: :view do
  before(:each) do
    @hist_friend = assign(:hist_friend, HistFriend.create!(
      :hist_from => nil,
      :hist_to => nil,
      :traced_by => nil,
      :traced_last_by => nil
    ))
  end

  it "renders the edit hist_friend form" do
    render

    assert_select "form[action=?][method=?]", hist_friend_path(@hist_friend), "post" do

      assert_select "input#hist_friend_hist_from_id[name=?]", "hist_friend[hist_from_id]"

      assert_select "input#hist_friend_hist_to_id[name=?]", "hist_friend[hist_to_id]"

      assert_select "textarea#hist_friend_traced_by[name=?]", "hist_friend[traced_by]"

      assert_select "input#hist_friend_traced_last_by[name=?]", "hist_friend[traced_last_by]"
    end
  end
end
