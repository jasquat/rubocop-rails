# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks dynamic `find_by_*` methods.
      # Use `find_by` instead of dynamic method.
      # See. https://rails.rubystyle.guide#find_by
      #
      # @example
      #   # bad
      #   User.find_by_name(name)
      #   User.find_by_name_and_email(name)
      #   User.find_by_email!(name)
      #
      #   # good
      #   User.find_by(name: name)
      #   User.find_by(name: name, email: email)
      #   User.find_by!(email: email)
      #
      # @example AllowedMethods: find_by_sql
      #   # bad
      #   User.find_by_query(users_query)
      #
      #   # good
      #   User.find_by_sql(users_sql)
      #
      # @example AllowedReceivers: Gem::Specification
      #   # bad
      #   Specification.find_by_name('backend').gem_dir
      #
      #   # good
      #   Gem::Specification.find_by_name('backend').gem_dir
      class DynamicFindAllBy < Base
        include ActiveRecordHelper
        extend AutoCorrector

        MSG = 'Use `%<static_name>s` instead of dynamic `%<method>s`.'
        METHOD_PATTERN = /^find_all_by_(.+?)$/.freeze
        IGNORED_ARGUMENT_TYPES = %i[splat].freeze
        METHOD_MAPPING = { conditions: :where, include: :includes }.freeze

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def on_send(node)
          return if node.receiver.nil? && !inherit_active_record_base?(node) || allowed_invocation?(node)

          method_name = node.method_name
          static_name = static_method_name(method_name)
          return if !static_name || method_is_reserved?(method_name) || node.arguments.first.type.to_s == 'hash'
          return if node.arguments.any? { |argument| IGNORED_ARGUMENT_TYPES.include?(argument.type) }

          message = format(MSG, static_name: static_name, method: method_name)
          add_offense(node, message: message) do |corrector|
            autocorrect(corrector, node)
          end
        end
        alias on_csend on_send
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/CyclomaticComplexity

        private

        def autocorrect(corrector, node)
          keywords = column_keywords(node.method_name)

          method_calls = if (hash_node = find_hash_from_node(node))
                           hash_node.children.map do |hash_element|
                             method_name = hash_key_to_arel_method(hash_element.key.value)
                             contents = hash_element.value.source
                             "#{method_name}(#{contents})"
                           end
                         else
                           []
                         end

          # add 1 back in for the hash
          return if keywords.size + (method_calls.any? ? 1 : 0) != node.arguments.size

          receiver_string = ''
          receiver_string = "#{node.children.first.source}." if node.children.first
          arguments = autocorrect_argument_keywords(corrector, node, keywords)
          replacement_string = "#{receiver_string}#{static_method_name(node.method_name.to_s)}(#{arguments.join(', ')})"

          replacement_string += ".#{method_calls.join('.')}" if method_calls.any?

          corrector.replace(node.loc.expression, replacement_string)
        end

        def find_hash_from_node(node)
          node.arguments.detect(&:hash_type?)
        end

        def hash_key_to_arel_method(method_name)
          METHOD_MAPPING[method_name] || method_name
        end

        def allowed_invocation?(node)
          allowed_method?(node) || allowed_receiver?(node)
        end

        def allowed_method?(node)
          return unless cop_config['AllowedMethods']

          cop_config['AllowedMethods'].include?(node.method_name.to_s)
        end

        def allowed_receiver?(node)
          return unless cop_config['AllowedReceivers'] && node.receiver

          cop_config['AllowedReceivers'].include?(node.receiver.source)
        end

        def autocorrect_method_name(corrector, node)
          corrector.replace(node.loc.selector,
                            static_method_name(node.method_name.to_s))
        end

        def autocorrect_argument_keywords(_corrector, node, keywords)
          keywords.map.with_index do |keyword, idx|
            "#{keyword}#{node.arguments[idx].source}"
          end
        end

        def column_keywords(method)
          keyword_string = method.to_s[METHOD_PATTERN, 1]
          keyword_string.split('_and_').map { |keyword| "#{keyword}: " }
        end

        # Returns static method name.
        # If code isn't wrong, returns nil
        def static_method_name(method_name)
          match = METHOD_PATTERN.match(method_name)
          return nil unless match

          'where'
        end

        def method_is_reserved?(method_name)
          return unless ENV['RUBOCOP_RAILS_FIND_BY_RESERVED_METHODS']

          contents = ENV['RUBOCOP_RAILS_FIND_BY_RESERVED_METHODS'].split(',')
          contents.grep(/^#{method_name}$/).any?
        end
      end
    end
  end
end
