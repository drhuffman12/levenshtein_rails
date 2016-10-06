require 'rails_helper'

RSpec.describe "social_nodes/new", type: :view do
  before(:each) do
    assign(:social_node, SocialNode.new(
      :word_orig => nil,
      :word_from => nil,
      :word_to => nil,
      :qty_steps => 1
    ))
  end

  it "renders new social_node form" do
    render

    assert_select "form[action=?][method=?]", social_nodes_path, "post" do

      assert_select "input#social_node_word_orig_id[name=?]", "social_node[word_orig_id]"

      assert_select "input#social_node_word_from_id[name=?]", "social_node[word_from_id]"

      assert_select "input#social_node_word_to_id[name=?]", "social_node[word_to_id]"

      assert_select "input#social_node_qty_steps[name=?]", "social_node[qty_steps]"
    end
  end
end
