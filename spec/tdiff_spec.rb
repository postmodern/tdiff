require 'spec_helper'
require 'tdiff_examples'

require 'tdiff/tdiff'

describe TDiff do
  include Helpers::Trees

  it_should_behave_like 'TDiff', :tdiff

  it "should detect when the order of children has changed" do
    changes = @tree.tdiff(@changed_order).to_a

    changes.length.should == 6

    changes[0][0].should == ' '
    changes[0][1].should == @tree

    changes[1][0].should == '-'
    changes[1][1].should == @tree.children[0]

    changes[2][0].should == ' '
    changes[2][1].should == @tree.children[1]

    changes[3][0].should == '+'
    changes[3][1].should == @changed_order.children[1]

    changes[4][0].should == ' '
    changes[4][1].should == @tree.children[1].children[0]

    changes[5][0].should == ' '
    changes[5][1].should == @tree.children[1].children[1]
  end
end
