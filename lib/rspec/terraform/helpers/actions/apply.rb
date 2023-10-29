# frozen_string_literal: true

require 'ruby_terraform'

require_relative 'command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Apply
          include CommandInstantiation

          def apply(parameters)
            parameters = apply_parameters(parameters)

            log_apply_starting(parameters)
            log_apply_using_parameters(parameters)

            apply_command.execute(parameters)

            log_apply_complete
          end

          private

          def log_apply_starting(parameters)
            logger&.info(
              'Applying for configuration in directory: ' \
              "'#{parameters[:chdir]}'..."
            )
          end

          def log_apply_using_parameters(parameters)
            logger&.debug("Applying using parameters: #{parameters}...")
          end

          def log_apply_complete
            logger&.info('Apply complete.')
          end

          def apply_command
            instantiate_command(RubyTerraform::Commands::Apply)
          end

          def apply_parameters(parameters)
            with_apply_state_file_parameters(
              with_apply_standard_parameters(parameters)
            )
          end

          def with_apply_standard_parameters(parameters)
            configuration_directory = parameters[:configuration_directory]

            parameters
              .except(:configuration_directory)
              .merge(
                chdir: configuration_directory,
                input: false,
                auto_approve: true
              )
          end

          def with_apply_state_file_parameters(parameters)
            state_file = parameters[:state_file]
            if state_file
              return parameters
                       .except(:state_file)
                       .merge(state: state_file)
            end

            parameters
          end
        end
      end
    end
  end
end
