# frozen_string_literal: true

require 'ruby_terraform'

require_relative './command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Destroy
          include CommandInstantiation

          def destroy(parameters)
            destroy_command.execute(destroy_parameters(parameters))
          end

          private

          def destroy_command
            instantiate_command(RubyTerraform::Commands::Destroy)
          end

          def destroy_parameters(parameters)
            with_destroy_state_file_parameters(
              with_destroy_standard_parameters(parameters)
            )
          end

          def with_destroy_standard_parameters(parameters)
            parameters.merge(
              chdir: parameters[:configuration_directory],
              input: false,
              auto_approve: true
            )
          end

          def with_destroy_state_file_parameters(parameters)
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
