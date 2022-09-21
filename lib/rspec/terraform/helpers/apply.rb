# frozen_string_literal: true

require 'ruby_terraform'

require_relative './base'
require_relative '../configuration/var_captor'

module RSpec
  module Terraform
    module Helpers
      class Apply < Base
        def execute(overrides = {}, &block)
          parameters = with_configuration_provider_parameters(overrides)
          parameters = with_resolved_vars(parameters, &block)
          parameters = with_mandatory_parameters(parameters)

          execute_if_required(parameters) do
            validate(parameters)
            clean(parameters)
            init(parameters)
            apply(parameters)
          end
        end

        private

        def execute_if_required(parameters, &block)
          only_if = parameters[:only_if]
          only_if_args = only_if ? [parameters].slice(0, only_if.arity) : []
          should_execute = only_if ? only_if.call(*only_if_args) : true

          block.call if should_execute
        end

        def mandatory_parameters
          {
            input: false,
            auto_approve: true
          }
        end

        def required_parameters(execution_mode)
          {
            in_place: [:configuration_directory],
            isolated: %i[source_directory configuration_directory]
          }[execution_mode] || []
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
          RubyTerraform::Commands::Init.new(command_options)
        end

        def apply_command
          RubyTerraform::Commands::Apply.new(command_options)
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
