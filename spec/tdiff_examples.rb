require 'spec_helper'
require 'helpers/trees'

shared_examples_for 'TDiff' do |method|
  include Helpers::Trees

  it "should tell if two trees are identical" do
    expect(
      @tree.send(method,@tree).all? { |change,node| change == ' ' }
    ).to be true
  end

  it "should stop if the root nodes have changed" do
    changes = @tree.send(method,@different_root).to_a

    expect(changes.length).to be 2

    expect(changes[0][0]).to be == '-'
    expect(changes[0][1]).to be == @tree

    expect(changes[1][0]).to be == '+'
    expect(changes[1][1]).to be == @different_root
  end

  it "should tell when sub-nodes are added" do
    changes = @tree.send(method,@added).select { |change,node| change == '+' }

    expect(changes.length).to be 1
    expect(changes[0][0]).to be == '+'
    expect(changes[0][1]).to be == @added.children[0].children[1]
  end

  it "should tell when sub-nodes are removed" do
    changes = @tree.send(method,@removed).select { |change,node| change == '-' }

    expect(changes.length).to be 1
    expect(changes[0][0]).to be == '-'
    expect(changes[0][1]).to be == @tree.children[0].children[1]
  end
end
