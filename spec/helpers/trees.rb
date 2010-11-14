require 'classes/node'

module Helpers
  module Trees
    def self.included(base)
      base.module_eval do
        before(:all) do
          @tree = Node.new('root', [
                    Node.new('leaf1', [
                      Node.new('subleaf1', []),
                      Node.new('subleaf2', [])
                    ]),

                    Node.new('leaf2', [
                      Node.new('subleaf1', []),
                      Node.new('subleaf2', [])
                    ])
                  ])

          @different_root = Node.new('wrong', [])

          @added = Node.new('root', [
                     Node.new('leaf1', [
                       Node.new('subleaf1', []),
                       Node.new('subleaf3', []),
                       Node.new('subleaf2', [])
                     ]),

                     Node.new('leaf2', [
                       Node.new('subleaf1', []),
                       Node.new('subleaf2', [])
                     ])
                   ])

          @removed = Node.new('root', [
                       Node.new('leaf1', [
                         Node.new('subleaf1', [])
                       ]),

                       Node.new('leaf2', [
                         Node.new('subleaf1', []),
                         Node.new('subleaf2', [])
                       ])
                     ])

          @changed_order = Node.new('root', [
                             Node.new('leaf2', [
                               Node.new('subleaf1', []),
                               Node.new('subleaf2', [])
                             ]),

                             Node.new('leaf1', [
                               Node.new('subleaf1', []),
                               Node.new('subleaf2', [])
                             ])
                           ])
        end
      end
    end
  end
end
