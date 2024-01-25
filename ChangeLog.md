### 0.4.0 / 2024-01-24

* Require [ruby](http://www.ruby-lang.org/) >= 2.0.0.
* Switched to using `require_relative` to improve load-times.
* Added `# frozen_string_literal: true` to all files.

### 0.3.4 / 2018-06-11

* Fixed shadowed variable warning (@bhollis).

### 0.3.3 / 2012-05-28

* Require ruby >= 1.8.7.
* Added {TDiff::VERSION}.
* Replaced ore-tasks with
  [rubygems-tasks](https://github.com/postmodern/rubygems-tasks#readme).

### 0.3.2 / 2010-11-28

* Added {TDiff#tdiff_recursive} to only handle recursively traversing
  and diffing the children nodes.
* Added {TDiff::Unordered#tdiff_recursive_unordered} to only handle
  recursively traversing and diffing the children nodes, without respecting
  the order of the nodes.

### 0.3.1 / 2010-11-28

* Fixed a typo in {TDiff::Unordered#tdiff_unordered}, which was causing
  all nodes to be marked as added.

### 0.3.0 / 2010-11-15

* Changed {TDiff#tdiff_equal} to compare `self` with another node.

### 0.2.0 / 2010-11-14

* Added {TDiff::Unordered}.

### 0.1.0 / 2010-11-13

* Initial release:
  * Provides the {TDiff} mixin.
  * Allows custom node equality and traversal logic by overriding the
    {TDiff#tdiff_equal} and {TDiff#tdiff_each_child} methods.
  * Implements the [Longest Common Subsequence (LCS)](http://en.wikipedia.org/wiki/Longest_common_subsequence_problem).

