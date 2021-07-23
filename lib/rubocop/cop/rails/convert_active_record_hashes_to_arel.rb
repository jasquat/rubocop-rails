# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks dynamic `find_by_*` methods.
      class ConvertActiveRecordHashesToArel < Base
        include ActiveRecordHelper
        extend AutoCorrector

        MSG = 'Use `arel` instead of `all`.'
        METHOD_MAPPING = { conditions: :where, include: :includes }.freeze

        def_node_matcher :method_call_to_all, <<-PATTERN
          (send _ :all (hash ...))
        PATTERN

        def_node_matcher :method_call_to_find_all, <<-PATTERN
          (send _ :find (:sym :all) (hash ...))
        PATTERN

        def on_send(node)
          return unless method_call_to_all(node) || method_call_to_find_all(node)

          message = format(MSG)
          add_offense(node, message: message) do |corrector|
            autocorrect(corrector, node)
          end
        end
        alias on_csend on_send

        private

        def autocorrect(corrector, node)
          method_calls = find_hash_from_node(node).children.map do |hash_element|
            method_name = hash_key_to_arel_method(hash_element.key.value)
            contents = hash_element.value.source
            "#{method_name}(#{contents})"
          end

          corrector.replace(node.loc.expression, "#{node.children.first.source}.#{method_calls.join('.')}")
        end

        def find_hash_from_node(node)
          node.arguments.detect(&:hash_type?)
        end

        def hash_key_to_arel_method(method_name)
          METHOD_MAPPING[method_name] || method_name
        end
      end
    end
  end
end
