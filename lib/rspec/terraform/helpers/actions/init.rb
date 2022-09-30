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
            parameters = init_parameters(parameters)

            log_init_starting(parameters)
            log_init_using_parameters(parameters)

            init_command.execute(parameters)

            log_init_complete
          end

          private

          def log_init_starting(parameters)
            logger&.info(
              'Initing for configuration in directory: ' \
              "'#{parameters[:chdir]}'..."
            )
          end

          def log_init_using_parameters(parameters)
            logger&.debug("Initing using parameters: #{parameters}...")
          end

          def log_init_complete
            logger&.info('Init complete.')
          end

          def init_command
            instantiate_command(RubyTerraform::Commands::Init)
          end

          def init_parameters(parameters)
            with_init_execution_mode_parameters(
              with_init_standard_parameters(parameters)
            )
          end

          def with_init_standard_parameters(parameters)
            configuration_directory = parameters[:configuration_directory]

            parameters
              .except(:configuration_directory)
              .merge(
                chdir: configuration_directory,
                input: false
              )
          end

          def with_init_execution_mode_parameters(parameters)
            source_directory = parameters[:source_directory]
            parameters = parameters.except(:source_directory)

            if execution_mode == :isolated
              return parameters.merge(from_module: source_directory)
            end

            parameters
          end
        end
      end
    end
  end
end
