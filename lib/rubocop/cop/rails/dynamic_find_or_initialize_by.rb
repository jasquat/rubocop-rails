# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks dynamic `find_or_initialize_by_*` methods.
      # Use `find_or_initialize_by` instead of dynamic method.
      # See. https://rails.rubystyle.guide#find_or_initialize_by
      #
      # @example
      #   # bad
      #   User.find_or_initialize_by_name(name)
      #   User.find_or_initialize_by_name_and_email(name)
      #   User.find_or_initialize_by_email!(name)
      #
      #   # good
      #   User.find_or_initialize_by(name: name)
      #   User.find_or_initialize_by(name: name, email: email)
      #   User.find_or_initialize_by!(email: email)
      #
      # @example AllowedMethods: find_or_initialize_by_sql
      #   # bad
      #   User.find_or_initialize_by_query(users_query)
      #
      #   # good
      #   User.find_or_initialize_by_sql(users_sql)
      #
      # @example AllowedReceivers: Gem::Specification
      #   # bad
      #   Specification.find_or_initialize_by_name('backend').gem_dir
      #
      #   # good
      #   Gem::Specification.find_or_initialize_by_name('backend').gem_dir
      class DynamicFindOrInitializeBy < Base
        include ActiveRecordHelper
        extend AutoCorrector

        MSG = 'Use `%<static_name>s` instead of dynamic `%<method>s`.'
        METHOD_PATTERN = /^find_or_initialize_by_(.+?)$/.freeze
        IGNORED_ARGUMENT_TYPES = %i[hash splat].freeze

        def on_send(node)
          return if node.receiver.nil? && !inherit_active_record_base?(node)

          method_name = node.method_name
          static_name = static_method_name(method_name)
          return unless static_name
          return if node.arguments.any? { |argument| IGNORED_ARGUMENT_TYPES.include?(argument.type) }

          message = format(MSG, static_name: static_name, method: method_name)
          add_offense(node, message: message) do |corrector|
            autocorrect(corrector, node)
          end
        end
        alias on_csend on_send

        private

        def autocorrect(corrector, node)
          keywords = column_keywords(node.method_name)

          return if keywords.size != node.arguments.size

          autocorrect_method_name(corrector, node)
          autocorrect_argument_keywords(corrector, node, keywords)
        end

        def autocorrect_method_name(corrector, node)
          corrector.replace(node.loc.selector,
                            static_method_name(node.method_name.to_s))
        end

        def autocorrect_argument_keywords(corrector, node, keywords)
          keywords.each.with_index do |keyword, idx|
            corrector.insert_before(node.arguments[idx].loc.expression, keyword)
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

          'find_or_initialize_by'
        end
      end
    end
  end
end
