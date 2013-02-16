#
# {TDiff} adds the ability to calculate the differences between two tree-like
# objects. Simply include {TDiff} into the class which represents the tree
# nodes and define the {#tdiff_each_child} and {#tdiff_equal} methods.
#
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
  # Default method which compares nodes.
  #
  # @param [Object] node
  #   A node from the new tree.
  #
  # @return [Boolean]
  #   Specifies whether the nodes are equal.
  #
  def tdiff_equal(node)
    self == node
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
    unless tdiff_equal(tree)
      yield '-', self
      yield '+', tree
      return self
    end

    yield ' ', self

    tdiff_recursive(tree,&block)
    return self
  end

  protected

  #
  # Recursively compares the differences between the children nodes.
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
  # @since 0.3.2
  #
  def tdiff_recursive(tree,&block)
    c = Hash.new { |hash,key| hash[key] = Hash.new(0) }
    x = enum_for(:tdiff_each_child,self)
    y = enum_for(:tdiff_each_child,tree)

    x.each_with_index do |xi,i|
      y.each_with_index do |yj,j|
        c[i][j] = if xi.tdiff_equal(yj)
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
    yj, j = next_child[y_backtrack]

    until (i == -1 && j == -1)
      if (i != -1 && j != -1 && xi.tdiff_equal(yj))
        changes.unshift [' ', xi]
        unchanged.unshift [xi, yj]

        xi, i = next_child[x_backtrack]
        yj, j = next_child[y_backtrack]
      else
        if (j >= 0 && (i == -1 || c[i][j-1] >= c[i-1][j]))
          changes.unshift ['+', yj]

          yj, j = next_child[y_backtrack]
        elsif (i >= 0 && (j == -1 || c[i][j-1] < c[i-1][j]))
          changes.unshift ['-', xi]

          xi, i = next_child[x_backtrack]
        end
      end
    end

    # explicitly discard the c matrix
    c = nil

    # sequentially iterate over the changed nodes
    changes.each(&block)
    changes = nil

    # recurse down through unchanged nodes
    unchanged.each { |a,b| a.tdiff_recursive(b,&block) }
    unchanged = nil
  end
end
