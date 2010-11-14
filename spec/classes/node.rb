require 'tdiff'

class Node < Struct.new(:name, :children)

  include TDiff
  include TDiff::Unordered

  def tdiff_each_child(node,&block)
    node.children.each(&block)
  end

  def tdiff_equal(node1,node2)
    node1.name == node2.name
  end

end
