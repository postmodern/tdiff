require 'pp'

module TDiff
  #
  # Default method which will enumerate over every child of a parent node.
  #
  # @param [Object] node
  #   The parent node.
  #
  # @yield [child]
  #   The given block will be passed each child of the parent node.
  #
  def tdiff_each_child(node,&block)
    node.each(&block) if node.kind_of?(Enumerable)
  end

  #
  # Compares two nodes.
  #
  # @param [Object] original_node
  #   A node from the original tree.
  #
  # @param [Object] new_node
  #   A node from the new tree.
  #
  # @return [Boolean]
  #   Specifies whether the two nodes are equal.
  #
  def tdiff_equal(original_node,new_node)
    original_node == new_node
  end

  #
  # Finds the differences between `self` and another tree.
  #
  # @param [#tdiff_each_child] tree
  #   The other tree.
  #
  # @yield [state, node]
  #   The given block will be passed the added or removed nodes.
  #
  # @yieldparam ['+', '-'] state
  #   The state-change of the node.
  #
  # @yieldparam [Object] node
  #   A node from one of the two trees.
  #
  # @return [Enumerator]
  #   If no block is given, an Enumerator object will be returned.
  #
  def tdiff(tree,&block)
    return enum_for(:tdiff,tree) unless block

    # check if the nodes differ
    unless tdiff_equal(self,tree)
      yield '-', self
      yield '+', tree
      return self
    end

    c = Hash.new { |hash,key| hash[key] = Hash.new(0) }
    x = enum_for(:tdiff_each_child,self)
    y = enum_for(:tdiff_each_child,tree)

    x.each_with_index do |x_node,i|
      y.each_with_index do |y_node,j|
        c[i][j] = if tdiff_equal(x_node,y_node)
                    c[i-1][j-1] + 1
                  else
                    if c[i][j-1] > c[i-1][j]
                      c[i][j-1]
                    else
                      c[i-1][j]
                    end
                  end
      end
    end

    pp c

    changes = []

    x_backtrack = x.reverse_each.each_with_index
    y_backtrack = y.reverse_each.each_with_index

    x_node, i = x_backtrack.next
    y_node, j = y_backtrack.next

    loop do
      if tdiff_equal(x_node,y_node)
        break if (i == 0 && j == 0)

        x_node, i = x_backtrack.next
        y_node, j = y_backtrack.next
      else
        if (j > 0 && (i == 0 || c[i][j-1] >= c[i-1][j]))
          changes.unshift(['+', y_node])

          y_node, j = y_backtrack.next
        elsif (i > 0 && (j == 0 || c[i][j-1] < c[i-1][j]))
          changes.unshift(['-', x_node])

          x_node, i = x_backtrack.next
        end
      end
    end

    # explicitly discard the c matrix
    c = nil

    # sequentially iterate over the changed nodes
    changes.each(&block)
    return self
  end
end
