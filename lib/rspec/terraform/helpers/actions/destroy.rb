# frozen_string_literal: true

require 'ruby_terraform'

require_relative 'command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Destroy
          include CommandInstantiation

          def destroy(parameters)
            parameters = destroy_parameters(parameters)

            log_destroy_starting(parameters)
            log_destroy_using_parameters(parameters)

            destroy_command.execute(parameters)

            log_destroy_complete
          end

          private

          def log_destroy_starting(parameters)
            logger&.info(
              'Destroying for configuration in directory: ' \
              "'#{parameters[:chdir]}'..."
            )
          end

          def log_destroy_using_parameters(parameters)
            logger&.debug("Destroying using parameters: #{parameters}...")
          end

          def log_destroy_complete
            logger&.info('Destroy complete.')
          end

          def destroy_command
            instantiate_command(RubyTerraform::Commands::Destroy)
          end

          def destroy_parameters(parameters)
            with_destroy_state_file_parameters(
              with_destroy_standard_parameters(parameters)
            )
          end

          def with_destroy_standard_parameters(parameters)
            configuration_directory = parameters[:configuration_directory]

            parameters
              .except(:configuration_directory)
              .merge(
                chdir: configuration_directory,
                input: false,
                auto_approve: true
              )
          end

          def with_destroy_state_file_parameters(parameters)
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
