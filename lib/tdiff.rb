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
  # @yieldparam [' ', '+', '-'] state
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

    xi, i = begin
              x_backtrack.next
            rescue StopIteration
            end

    yi, j = begin
              y_backtrack.next
            rescue StopIteration
            end

    # handle single child edge-cases
    if (xi.nil? || yi.nil?)
      if (xi.nil? && yi)
        yield '+', yi
      elsif (xi && yi.nil?)
        yield '-', xi
      end

      return self
    end

    loop do
      if tdiff_equal(xi,yi)
        unchanged << [xi, yi]

        break if (i == 0 && j == 0)

        xi, i = x_backtrack.next
        yi, j = y_backtrack.next
      else
        if (j > 0 && (i == 0 || c[i][j-1] >= c[i-1][j]))
          changes.unshift(['+', yi])

          yi, j = y_backtrack.next
        elsif (i > 0 && (j == 0 || c[i][j-1] < c[i-1][j]))
          changes.unshift(['-', xi])

          xi, i = x_backtrack.next
        end
      end
    end

    # explicitly discard the c matrix
    c = nil

    # recurse down through unchanged nodes
    unchanged.each do |xi,yi|
      yield ' ', xi

      xi.tdiff(yi,&block)
    end
    unchanged = nil

    # sequentially iterate over the changed nodes
    changes.each(&block)
    changes = nil

    return self
  end
end
