require 'spec_helper'
require 'helpers/trees'
require 'tdiff_examples'
require 'tdiff/tdiff'

describe TDiff do
  include Helpers::Trees

  it_should_behave_like 'TDiff', :tdiff

  it "should tell when sub-nodes are added" do
    changes = @tree.tdiff(@added).select { |change,node| change == '+' }

    changes.length.should == 1
    changes[0][0].should == '+'
    changes[0][1].should == @added.children[0].children[1]
  end

  it "should tell when sub-nodes are removed" do
    changes = @tree.tdiff(@removed).select { |change,node| change == '-' }

    changes.length.should == 1
    changes[0][0].should == '-'
    changes[0][1].should == @tree.children[0].children[1]
  end

  it "should detect when the order of children has changed" do
    changes = @tree.tdiff(@changed_order).to_a

    changes.length.should == 5
    changes[0][0].should == '-'
    changes[0][1].should == @tree.children[0]

    changes[1][0].should == ' '
    changes[1][1].should == @tree.children[1]

    changes[2][0].should == '+'
    changes[2][1].should == @changed_order.children[1]

    changes[3][0].should == ' '
    changes[3][1].should == @tree.children[1].children[0]

    changes[4][0].should == ' '
    changes[4][1].should == @tree.children[1].children[1]
  end
end
