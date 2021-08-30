# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      class ConvertActiveRecordHashesToArel < Base
        include ActiveRecordHelper
        extend AutoCorrector

        MSG = 'Use `arel` instead of `%<method>s`.'
        METHOD_MAPPING = { conditions: :where, include: :includes }.freeze

        def_node_matcher :method_call_to_all, <<-PATTERN
          (send _ :all (hash ...))
        PATTERN

        def_node_matcher :method_call_to_find_all, <<-PATTERN
          (send _ :find (:sym :all) (hash ...))
        PATTERN

        def_node_matcher :method_call_to_find_symbol, <<-PATTERN
          (send _ :find (:sym {:all | :first}))
        PATTERN

        def_node_matcher :method_call_to_first, <<-PATTERN
          (send _ :first (hash ...))
        PATTERN

        def_node_matcher :method_call_to_count, <<-PATTERN
          (send _ :count (hash ...))
        PATTERN

        def_node_matcher :method_call_to_count_with_non_hash_arg, <<-PATTERN
          (send _ :count ({:str | :sym} _) hash)
        PATTERN

        def on_send(node)
          unless method_call_to_all(node) ||
                 method_call_to_find_all(node) ||
                 method_call_to_first(node) ||
                 method_call_to_count(node) ||
                 method_call_to_count_with_non_hash_arg(node) ||
                 method_call_to_find_symbol(node)
            return
          end

          message = format(MSG, method: node.method_name)
          add_offense(node, message: message) do |corrector|
            autocorrect(corrector, node)
          end
        end
        alias on_csend on_send

        private

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def autocorrect(corrector, node)
          method_calls = if (hash_node = find_hash_from_node(node))
                           hash_node.children.map do |hash_element|
                             method_name = hash_key_to_arel_method(hash_element.key.value)
                             contents = hash_element.value.source
                             "#{method_name}(#{contents})"
                           end
                         else
                           [node.arguments.first.value.to_s]
                         end

          if node.method?(:first)
            # See tests for the why
            if (where_call = method_calls.grep(/^where\(/).first)
              method_calls.delete(where_call)
              method_calls << where_call.sub(/^where\(/, 'find_by(')
            else
              method_calls << 'first'
            end
          elsif node.method?(:count)
            count_method_call = 'count'
            if (first_argument = node.arguments.first) && %i[str sym].include?(first_argument.type)
              count_method_call = "count(#{first_argument.source})"
            end
            method_calls << count_method_call
          end

          receiver_string = ''
          receiver_string = "#{node.children.first.source}." if node.children.first
          corrector.replace(node.loc.expression, "#{receiver_string}#{method_calls.join('.')}")
        end
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/CyclomaticComplexity

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
