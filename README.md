# TDiff

* [Source](http://github.com/postmodern/tdiff)
* [Issues](http://github.com/postmodern/tdiff/issues)
* Postmodern (postmodern.mod3 at gmail.com)

## Description

Calculates the differences between two tree-like structures. Similar to
Rubys built-in [TSort](http://rubydoc.info/docs/ruby-stdlib/1.9.2/TSort)
module.

## Features

* Provides the {TDiff} mixin.
* Provides the {TDiff::Unordered} mixin for unordered diffing.
* Allows custom node equality and traversal logic by overriding the
  {TDiff#tdiff_equal} and {TDiff#tdiff_each_child} methods.
* Implements the [Longest Common Subsequence (LCS)](http://en.wikipedia.org/wiki/Longest_common_subsequence_problem) algorithm.

## Examples

Diff two HTML documents:

    require 'nokogiri'
    require 'tdiff'

    class Nokogiri::XML::Node

      include TDiff

      def tdiff_equal(node)
        if (self.text? && node.text?)
          self.text == node.text
        elsif (self.respond_to?(:root) && node.respond_to?(:root))
          self.root.tdiff_equal(node.root)
        elsif (self.respond_to?(:name) && node.respond_to?(:name))
          self.name == node.name
        else
          false
        end
      end

      def tdiff_each_child(node,&block)
        node.children.each(&block)
      end

    end

    doc1 = Nokogiri::HTML('<div><p>one</p> <p>three</p></div>')
    doc2 = Nokogiri::HTML('<div><p>one</p> <p>two</p> <p>three</p></div>')

    doc1.at('div').tdiff(doc2.at('div')) do |change,node|
      puts "#{change} #{node.to_html}".ljust(30) + node.parent.path
    end

### Output

    + <p>one</p>                  /html/body/div
    +                             /html/body/div
      <p>one</p>                  /html/body/div
                                  /html/body/div
      <p>three</p>                /html/body/div
    - one                         /html/body/div/p[1]
    + two                         /html/body/div/p[2]
      three                       /html/body/div/p[2]

## Requirements

* [ruby](http://www.ruby-lang.org/) >= 1.8.7

## Install

    $ gem install tdiff

## Copyright

See {file:LICENSE.txt} for details.

