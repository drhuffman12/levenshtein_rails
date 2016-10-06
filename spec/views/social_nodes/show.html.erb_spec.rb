require 'rails_helper'

RSpec.describe "social_nodes/show", type: :view do
  before(:each) do
    @social_node = assign(:social_node, SocialNode.create!(
      :word_orig => nil,
      :word_from => nil,
      :word_to => nil,
      :qty_steps => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
  end
end
