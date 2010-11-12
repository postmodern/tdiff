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
  def tdiff_each_child(node)
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
    false
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
  def tdiff(tree)
    return enum_for(:tdiff,tree) unless block_given?

    unless tdiff_equal(self,tree)
      yield '-', self
      yield '+', tree
      return self
    end

    unchanged = {}

    tdiff_each_child(self) do |original_node|
      tdiff_each_child(tree) do |new_node|
        # the new node must not be claimed yet
        unless unchanged.values.include?(new_node)
          if tdiff_equal(original_node,new_node)
            # the original node was found in the new sub-tree
            unchanged[original_node] = new_node
            break
          end
        end
      end
    end

    changes = []

    enum_for(:tdiff_each_child,self).each_with_index do |node,index|
      unless unchanged.keys.include?(node)
        changes << [index, '-', node]
      end
    end

    enum_for(:tdiff_each_child,tree).each_with_index do |node,index|
      unless unchanged.values.include?(node)
        changes << [index, '+', node]
      end
    end

    changes.sort_by { |index,state,node| index }.each do |index,state,node|
      yield state, node
    end

    unchanged.each do |original_tree,new_tree|
      tdiff(original_tree,new_tree)
    end

    return self
  end
end