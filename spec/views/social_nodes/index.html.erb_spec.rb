require 'rails_helper'

RSpec.describe "social_nodes/index", type: :view do
  before(:each) do
    assign(:social_nodes, [
      SocialNode.create!(
        :word_orig => nil,
        :word_from => nil,
        :word_to => nil,
        :qty_steps => 2
      ),
      SocialNode.create!(
        :word_orig => nil,
        :word_from => nil,
        :word_to => nil,
        :qty_steps => 2
      )
    ])
  end

  it "renders a list of social_nodes" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
