# frozen_string_literal: true

require 'ruby_terraform'

require_relative './command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Init
          include CommandInstantiation

          def init(parameters)
            init_command.execute(init_parameters(parameters))
          end

          private

          def init_command
            instantiate_command(RubyTerraform::Commands::Init)
          end

          def init_parameters(parameters)
            with_init_execution_mode_parameters(
              with_init_standard_parameters(parameters)
            )
          end

          def with_init_standard_parameters(parameters)
            parameters.merge(
              chdir: parameters[:configuration_directory],
              input: false
            )
          end

          def with_init_execution_mode_parameters(parameters)
            if execution_mode == :isolated
              return parameters.merge(
                from_module: parameters[:source_directory]
              )
            end

            parameters
          end
        end
      end
    end
  end
end
