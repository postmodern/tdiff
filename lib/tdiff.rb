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
  # @yield [change, node]
  #   The given block will be passed the added or removed nodes.
  #
  # @yieldparam [' ', '+', '-'] change
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

    x.each_with_index do |xi,i|
      y.each_with_index do |yi,j|
        c[i][j] = if tdiff_equal(xi,yi)
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

    unchanged = []
    changes = []

    x_backtrack = x.each_with_index.reverse_each
    y_backtrack = y.each_with_index.reverse_each

    next_child = lambda { |children|
      begin
        children.next
      rescue StopIteration
        # end of iteration, return a -1 index
        [nil, -1]
      end
    }

    xi, i = next_child[x_backtrack]
    yi, j = next_child[y_backtrack]

    until (i == -1 && j == -1)
      if (i != -1 && j != -1 && tdiff_equal(xi,yi))
        changes.unshift [' ', xi]
        unchanged << [xi, yi]

        xi, i = next_child[x_backtrack]
        yi, j = next_child[y_backtrack]
      else
        if (j >= 0 && (i == -1 || c[i][j-1] >= c[i-1][j]))
          changes.unshift ['+', yi]

          yi, j = next_child[y_backtrack]
        elsif (i >= 0 && (j == -1 || c[i][j-1] < c[i-1][j]))
          changes.unshift ['-', xi]

          xi, i = next_child[x_backtrack]
        end
      end
    end

    # explicitly discard the c matrix
    c = nil

    # recurse down through unchanged nodes
    unchanged.each { |x,y| x.tdiff(y,&block) }
    unchanged = nil

    # sequentially iterate over the changed nodes
    changes.each(&block)
    changes = nil

    return self
  end
end
