# frozen_string_literal: true

require 'ruby_terraform'

require_relative './command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Apply
          include CommandInstantiation

          def apply(parameters)
            apply_command.execute(apply_parameters(parameters))
          end

          private

          def apply_command
            instantiate_command(RubyTerraform::Commands::Apply)
          end

          def apply_parameters(parameters)
            with_apply_state_file_parameters(
              with_apply_standard_parameters(parameters)
            )
          end

          def with_apply_standard_parameters(parameters)
            parameters.merge(
              chdir: parameters[:configuration_directory],
              input: false,
              auto_approve: true
            )
          end

          def with_apply_state_file_parameters(parameters)
            if parameters[:state_file]
              return parameters.merge(state: parameters[:state_file])
            end

            parameters
          end
        end
      end
    end
  end
end
