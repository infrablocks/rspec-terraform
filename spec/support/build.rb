# frozen_string_literal: true

require_relative 'random'

module Support
  # rubocop:disable Metrics/ModuleLength
  module Build
    # rubocop:disable Metrics/ClassLength
    class << self
      def change_content_defaults_for_resource
        { actions: ['create'],
          before: {},
          after: {
            standard_attribute: Support::Random.alphanumeric_string,
            sensitive_attribute: Support::Random.alphanumeric_string
          },
          after_unknown: { unknown_attribute: true },
          before_sensitive: {},
          after_sensitive: { sensitive_attribute: true } }
      end

      def change_content_defaults_for_output
        { actions: ['create'],
          before: nil,
          before_sensitive: false,
          after: Support::Random.alphanumeric_string,
          after_unknown: false,
          after_sensitive: false }
      end

      def change_content_defaults(type)
        case type
        when :resource then change_content_defaults_for_resource
        when :output then change_content_defaults_for_output
        else {}
        end
      end

      def no_op_change_content(overrides = {})
        change_content(overrides.merge(actions: ['no-op']))
      end

      def create_change_content(overrides = {}, opts = {})
        change_content(overrides.merge(actions: ['create']), opts)
      end

      def read_change_content(overrides = {})
        change_content(overrides.merge(actions: ['read']))
      end

      def update_change_content(overrides = {}, opts = {})
        change_content(overrides.merge(actions: ['update']), opts)
      end

      def replace_delete_before_create_change_content(overrides = {})
        change_content(overrides.merge(actions: %w[delete create]))
      end

      def replace_create_before_delete_change_content(overrides = {})
        change_content(overrides.merge(actions: %w[create delete]))
      end

      def replace_change_content(overrides = {})
        change_content(
          overrides.merge(
            actions: [%w[create delete], %w[delete create]].sample
          )
        )
      end

      def delete_change_content(overrides = {}, opts = {})
        change_content(overrides.merge(actions: ['delete']), opts)
      end

      def change_content(overrides = {}, opts = {})
        change_content_defaults(opts[:type] || :resource).merge(overrides)
      end

      # rubocop:disable Metrics/MethodLength
      def resource_change_content(
        overrides = {},
        opts = {}
      )
        opts = {
          module_resource: false,
          multi_instance_resource: false
        }.merge(opts)

        defaults = {
          module_address: resolved_resource_module_address(overrides, opts),
          mode: 'managed',
          type: resolved_resource_type(overrides),
          name: resolved_resource_name(overrides),
          index: resolved_resource_index(overrides, opts),
          provider_name: resolved_resource_provider_name(overrides),
          change: change_content
        }

        defaults = defaults.merge(
          address: resolved_resource_address(overrides, defaults, opts)
        )

        defaults.merge(overrides)
      end

      # rubocop:enable Metrics/MethodLength

      def output_change_content(overrides = {})
        change_content(overrides, { type: :output })
      end

      def variable_content(overrides = {})
        {
          value: Support::Random.alphanumeric_string
        }.merge(overrides)
      end

      # rubocop:disable Metrics/MethodLength
      def plan_content(overrides = {})
        {
          format_version: '1.0',
          terraform_version: '1.1.5',
          variables: {
            variable1: variable_content,
            variable2: variable_content
          },
          resource_changes: [
            Support::Build.resource_change_content,
            Support::Build.resource_change_content
          ],
          output_changes: {
            Support::Random.output_name =>
              Support::Build.output_change_content,
            Support::Random.output_name =>
              Support::Build.output_change_content
          }
        }.merge(overrides)
      end

      # rubocop:enable Metrics/MethodLength

      private

      def resolved_resource_provider_name(overrides)
        overrides[:provider_name] || Support::Random.provider_name
      end

      def resolved_resource_type(overrides)
        overrides[:type] || Support::Random.resource_type
      end

      def resolved_resource_name(overrides)
        overrides[:name] || Support::Random.resource_name
      end

      def resolved_resource_index(overrides, opts)
        return overrides[:index] if overrides[:index]
        return nil unless opts[:multi_instance_resource]

        Support::Random.resource_index
      end

      def resolved_resource_module_address(overrides, opts)
        return overrides[:module_address] if overrides[:module_address]
        return nil unless opts[:module_resource]

        Support::Random.module_address
      end

      def resolved_resource_address(overrides, defaults, opts)
        return overrides[:address] if overrides[:address]

        if opts[:module_resource]
          module_resource_address(defaults)
        else
          standard_resource_address(defaults)
        end
      end

      def module_resource_address(values)
        module_address = values[:module_address]
        type = values[:type]
        name = values[:name]
        index = values[:index] ? "[#{values[:index]}]" : ''

        "#{module_address}.#{type}.#{name}#{index}"
      end

      def standard_resource_address(values)
        type = values[:type]
        name = values[:name]
        index = values[:index] ? "[#{values[:index]}]" : ''

        "#{type}.#{name}#{index}"
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
  # rubocop:enable Metrics/ModuleLength
end
