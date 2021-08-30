# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      class ConvertHasManyHashesToArel < Base
        include ActiveRecordHelper
        extend AutoCorrector

        MSG = 'Use `arel` instead of hash with options.'
        METHOD_MAPPING = { conditions: :where, include: :includes }.freeze

        def_node_matcher :has_many_method_call, <<-PATTERN
          (send _ :has_many (sym _) (hash ...))
        PATTERN

        def on_send(node)
          return unless has_many_method_call(node)

          hash_node = find_hash_from_node(node)
          normalized_key_names = hash_node.keys.map(&:source).map { |key| key.sub(/^:/, '') }
          return if (normalized_key_names - keys_to_exclude).count == 0

          message = format(MSG, method: node.method_name)
          add_offense(node, message: message) do |corrector|
            autocorrect(corrector, node)
          end
        end
        alias on_csend on_send

        private

        def autocorrect(corrector, node)
          arel_method_calls = []
          excluded_method_calls = []
          if (hash_node = find_hash_from_node(node))
            hash_node.children.each do |hash_element|
              method_name = hash_key_to_arel_method(hash_element.key.value)
              contents = hash_element.value.source
              if keys_to_exclude.include?(method_name.to_s)
                excluded_method_calls << hash_element.source
              else
                arel_method_calls << "#{method_name}(#{contents})"
              end
            end
          end

          return if arel_method_calls.empty?

          receiver_string = ''
          receiver_string = "#{node.children.first.source}." if node.children.first
          receiver_string += "has_many #{node.arguments.first.source}, "

          excluded_method_string = ", #{excluded_method_calls.join(', ')}" if excluded_method_calls.any?
          corrector.replace(node.loc.expression,
                            "#{receiver_string}-> { #{arel_method_calls.join('.')} }#{excluded_method_string}")
        end

        def find_hash_from_node(node)
          node.arguments.detect(&:hash_type?)
        end

        def keys_to_exclude
          %w[
            as
            class_name
            dependent
            extend
            foreign_key
            polymorphic
            through
          ]
        end

        def hash_key_to_arel_method(method_name)
          METHOD_MAPPING[method_name] || method_name
        end
      end
    end
  end
end
