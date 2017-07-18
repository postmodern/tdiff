require 'spec_helper'
require 'tdiff_examples'

require 'tdiff/tdiff'

describe TDiff do
  include Helpers::Trees

  it_should_behave_like 'TDiff', :tdiff

  it "should detect when the order of children has changed" do
    changes = @tree.tdiff(@changed_order).to_a

    expect(changes.length).to be == 6

    expect(changes[0][0]).to be == ' '
    expect(changes[0][1]).to be == @tree

    expect(changes[1][0]).to be == '-'
    expect(changes[1][1]).to be == @tree.children[0]

    expect(changes[2][0]).to be == ' '
    expect(changes[2][1]).to be == @tree.children[1]

    expect(changes[3][0]).to be == '+'
    expect(changes[3][1]).to be == @changed_order.children[1]

    expect(changes[4][0]).to be == ' '
    expect(changes[4][1]).to be == @tree.children[1].children[0]

    expect(changes[5][0]).to be == ' '
    expect(changes[5][1]).to be == @tree.children[1].children[1]
  end
end
