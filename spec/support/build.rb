# frozen_string_literal: true

require_relative './random'

module Support
  # rubocop:disable Metrics/ModuleLength
  module Build
    class << self
      def no_op_change_content(overrides = {})
        change_content(overrides.merge(actions: ['no-op']))
      end

      def create_change_content(overrides = {})
        change_content(overrides.merge(actions: ['create']))
      end

      def read_change_content(overrides = {})
        change_content(overrides.merge(actions: ['read']))
      end

      def update_change_content(overrides = {})
        change_content(overrides.merge(actions: ['update']))
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

      def delete_change_content(overrides = {})
        change_content(overrides.merge(actions: ['delete']))
      end

      # rubocop:disable Metrics/MethodLength
      def change_content(overrides = {})
        {
          actions: ['create'],
          before: {},
          after: {
            standard_attribute: 'value1',
            sensitive_attribute: 'value2'
          },
          after_unknown: {
            unknown_attribute: true
          },
          before_sensitive: {},
          after_sensitive: {
            sensitive_attribute: true
          }
        }.merge(overrides)
      end

      # rubocop:enable Metrics/MethodLength

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
          ]
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
        "#{values[:module_address]}.#{values[:type]}.#{values[:name]}"
      end

      def standard_resource_address(values)
        "#{values[:type]}.#{values[:name]}"
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
