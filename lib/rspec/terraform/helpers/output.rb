# frozen_string_literal: true

require 'ruby_terraform'

require_relative './base'

module RSpec
  module Terraform
    module Helpers
      class Output < Base
        def execute(overrides = {})
          parameters = with_configuration_provider_parameters(overrides)
          parameters = with_mandatory_parameters(parameters)

          validate(parameters)
          clean(parameters)
          init(parameters)
          output_value = output(parameters)

          JSON.parse(output_value, symbolize_names: true)
        end

        private

        def with_mandatory_parameters(parameters)
          parameters.merge(mandatory_parameters)
        end

        def mandatory_parameters
          {
            json: true
          }
        end

        def required_parameters(execution_mode)
          {
            in_place: %i[name configuration_directory],
            isolated: %i[name source_directory configuration_directory]
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

        def output(parameters)
          stdout = StringIO.new
          output_command(stdout: stdout)
            .execute(output_parameters(parameters))
          stdout.string
        end

        def init_command
          RubyTerraform::Commands::Init.new(command_options)
        end

        def output_command(opts = {})
          RubyTerraform::Commands::Output.new(command_options.merge(opts))
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

        def output_parameters(parameters)
          output_parameters =
            parameters.merge(
              chdir: parameters[:configuration_directory]
            )

          if parameters[:state_file]
            output_parameters =
              output_parameters.merge(state: parameters[:state_file])
          end

          output_parameters
        end
      end
    end
  end
end
