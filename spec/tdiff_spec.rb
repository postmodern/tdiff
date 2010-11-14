require 'spec_helper'
require 'classes/node'
require 'tdiff'

describe TDiff do
  before(:all) do
    @tree = Node.new('root', [
      Node.new('leaf1', [
        Node.new('subleaf1', [])
      ]),

      Node.new('leaf2', [
        Node.new('subleaf1', [])
      ])
    ])

    @different_root = Node.new('wrong', [])

    @added = Node.new('root', [
      Node.new('leaf1', [
        Node.new('subleaf1', []),
        Node.new('subleaf2', [])
      ]),

      Node.new('leaf2', [
        Node.new('subleaf1', [])
      ])
    ])

    @removed = Node.new('root', [
      Node.new('leaf1', []),

      Node.new('leaf2', [
        Node.new('subleaf1', [])
      ])
    ])

    @changed_order = Node.new('root', [
      Node.new('leaf2', [
        Node.new('subleaf1', [])
      ]),

      Node.new('leaf1', [
        Node.new('subleaf1', [])
      ])
    ])
  end

  it "should tell if two trees are identical" do
    @tree.tdiff(@tree).to_a.should be_empty
  end

  it "should stop if the root nodes have changed" do
    changes = @tree.tdiff(@different_root).to_a

    changes.length.should == 2

    changes[0][0].should == '-'
    changes[0][1].should == @tree

    changes[1][0].should == '+'
    changes[1][1].should == @different_root
  end

  it "should tell when sub-nodes are added" do
    changes = @tree.tdiff(@added).to_a

    changes.length.should == 1
    changes[0][0].should == '+'
    changes[0][1].should == @added.children[0].children[1]
  end

  it "should tell when sub-nodes are removed" do
    changes = @tree.tdiff(@removed).to_a

    changes.length.should == 1
    changes[0][0].should == '-'
    changes[0][1].should == @tree.children[0].children[0]
  end

  it "should detect when the order of children has changed" do
    changes = @tree.tdiff(@changed_order).to_a

    changes.length.should == 4
    changes[0][0].should == '-'
    changes[0][1].should == @tree.children[0]

    changes[1][0].should == '+'
    changes[1][1].should == @changed_order.children[0]

    changes[2][0].should == '-'
    changes[2][1].should == @tree.children[1]

    changes[3][0].should == '+'
    changes[3][1].should == @changed_order.children[1]
  end
end
