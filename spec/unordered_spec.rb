require 'spec_helper'
require 'tdiff_examples'

require 'tdiff/unordered'

describe TDiff::Unordered do
  include Helpers::Trees

  it "should include TDiff when included" do
    base = Class.new do
      include TDiff::Unordered
    end

    base.should include(TDiff)
  end

  it_should_behave_like 'TDiff', :tdiff_unordered

  it "should not detect when the order of children has changed" do
    changes = @tree.tdiff_unordered(@changed_order).select do |change,node|
      change != ' '
    end

    changes.should be_empty
  end
end
