# frozen_string_literal: true

require 'ruby_terraform'

require_relative '../configuration/var_captor'

module RSpec
  module Terraform
    module Helpers
      class Apply
        attr_reader(
          :configuration_provider, :binary, :execution_mode
        )

        def initialize(opts = {})
          @configuration_provider =
            opts[:configuration_provider] || Configuration.identity_provider
          @binary = opts[:binary] || 'terraform'
          @execution_mode = opts[:execution_mode] || :in_place
        end

        def execute(overrides = {}, &block)
          parameters = with_configuration_provider_parameters(overrides)
          parameters = with_resolved_vars(parameters, &block)
          parameters = with_mandatory_parameters(parameters)

          ensure_required_parameters(parameters)

          clean(parameters)
          init(parameters)
          apply(parameters)
        end

        private

        def with_configuration_provider_parameters(parameters)
          configuration_provider.resolve(parameters)
        end

        def with_resolved_vars(parameters, &block)
          return parameters unless block_given?

          var_captor = Configuration::VarCaptor.new(parameters[:vars] || {})
          block.call(var_captor)
          parameters.merge(vars: var_captor.to_h)
        end

        def with_mandatory_parameters(parameters)
          parameters.merge(
            input: false,
            auto_approve: true
          )
        end

        def required_parameters(execution_mode)
          {
            in_place: [:configuration_directory],
            isolated: %i[source_directory configuration_directory]
          }[execution_mode] || []
        end

        def ensure_required_parameters(parameters)
          missing_parameters =
            required_parameters(execution_mode)
              .filter { |parameter| parameters[parameter].nil? }

          return if missing_parameters.empty?

          raise_missing_parameters(missing_parameters)
        end

        def raise_missing_parameters(parameters)
          parameters = parameters.collect { |parameter| "`:#{parameter}`" }
          if parameters.count == 1
            raise StandardError,
                  "Required parameter: #{parameters[0]} missing."
          else
            parameters = "#{parameters[..-2].join(', ')} and #{parameters[-1]}"
            raise StandardError,
                  "Required parameters: #{parameters} missing."
          end
        end

        def clean(parameters)
          return unless execution_mode == :isolated

          FileUtils.rm_rf(parameters[:configuration_directory])
          FileUtils.mkdir_p(parameters[:configuration_directory])
        end

        def init(parameters)
          init_command.execute(init_parameters(parameters))
        end

        def apply(parameters)
          apply_command.execute(apply_parameters(parameters))
        end

        def init_command
          RubyTerraform::Commands::Init.new(binary: binary)
        end

        def apply_command
          RubyTerraform::Commands::Apply.new(binary: binary)
        end

        def init_parameters(parameters)
          init_parameters = parameters.merge(
            chdir: parameters[:configuration_directory],
            input: false
          )
          if execution_mode == :isolated
            init_parameters =
              init_parameters.merge(from_module: parameters[:source_directory])
          end

          init_parameters
        end

        # rubocop:disable Metrics/MethodLength
        def apply_parameters(parameters)
          apply_parameters =
            parameters.merge(
              chdir: parameters[:configuration_directory],
              input: false,
              auto_approve: true
            )

          if parameters[:state_file]
            apply_parameters =
              apply_parameters.merge(state: parameters[:state_file])
          end

          apply_parameters
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
