require 'rails_helper'

RSpec.describe "social_nodes/edit", type: :view do
  before(:each) do
    @social_node = assign(:social_node, SocialNode.create!(
      :word_orig => nil,
      :word_from => nil,
      :word_to => nil,
      :qty_steps => 1
    ))
  end

  it "renders the edit social_node form" do
    render

    assert_select "form[action=?][method=?]", social_node_path(@social_node), "post" do

      assert_select "input#social_node_word_orig_id[name=?]", "social_node[word_orig_id]"

      assert_select "input#social_node_word_from_id[name=?]", "social_node[word_from_id]"

      assert_select "input#social_node_word_to_id[name=?]", "social_node[word_to_id]"

      assert_select "input#social_node_qty_steps[name=?]", "social_node[qty_steps]"
    end
  end
end
