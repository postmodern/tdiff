require 'tdiff/tdiff'

module TDiff
  #
  # Calculates the differences between two trees, without respecting the
  # order of children nodes.
  #
  module Unordered
    def self.included(base)
      base.send :include, TDiff
    end

    #
    # Finds the differences between `self` and another tree, not respecting
    # the ordering of children.
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
    # @since 0.2.0
    #
    def tdiff_unordered(tree,&block)
      return enum_for(:tdiff_unordered,tree) unless block

      # check if the nodes differ
      unless tdiff_equal(self,tree)
        yield '-', self
        yield '+', tree
        return self
      end

      x = enum_for(:tdiff_each_child,self)
      y = enum_for(:tdiff_each_child,tree)

      unchanged = {}
      changes = []

      x.each_with_index do |xi,i|
        y.each_with_index do |yj,j|
          if (!unchanged.has_value?(yj) && tdiff_equal(xi,yj))
            unchanged[xi] = yj
            changes << [i, ' ', xi]
            break
          end
        end

        unless unchanged.has_key?(xi)
          changes << [i, '-', xi]
        end
      end

      y.each_with_index do |yj,j|
        unless unchanged.has_key?(yj)
          changes << [j, '+', yj]
        end
      end

      # explicitly release the unchanged variable
      unchanged = nil

      # order the changes by index to match the behavior of `tdiff`
      changes.sort_by { |change| change[0] }.each do |index,change,node|
        yield change, node
      end

      return self
    end
  end
end
