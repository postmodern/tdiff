# TDiff

* [Source](http://github.com/postmodern/tdiff)
* [Issues](http://github.com/postmodern/tdiff/issues)
* Postmodern (postmodern.mod3 at gmail.com)

## Description

Calculates the differences between two tree-like structures. Similar to
Rubys builtin [TSort](http://rubydoc.info/docs/ruby-stdlib/1.9.2/TSort)
module.

## Examples

Diff two HTML documents:

    require 'nokogiri'
    require 'tdiff'

    class Nokogiri::XML::Node

      include TDiff

      def tdiff_each_child(node,&block)
        node.children.each(&block)
      end

      def tdiff_equal(node1,node2)
        if (node1.text? && node2.text?)
          node1.text == node2.text
        elsif (node1.respond_to?(:root) && node2.respond_to?(:root))
          tdiff_equal(node1.root,node2.root)
        elsif (node1.respond_to?(:name) && node2.respond_to?(:name))
          node1.name == node2.name
        else
          false
        end
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

## Install

    $ gem install tdiff

## Copyright

See {file:LICENSE.txt} for details.

