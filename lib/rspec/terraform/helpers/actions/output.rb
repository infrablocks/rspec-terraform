# frozen_string_literal: true

require 'ruby_terraform'
require 'stringio'

require_relative 'command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Output
          include CommandInstantiation

          def output(parameters)
            stdout = StringIO.new
            parameters = output_parameters(parameters)

            log_output_starting(parameters)
            log_output_using_parameters(parameters)

            output_command(stdout: stdout)
              .execute(parameters)

            log_output_complete

            stdout.string
          end

          private

          def log_output_starting(parameters)
            logger&.info(
              'Outputting for configuration in directory: ' \
              "'#{parameters[:chdir]}'..."
            )
          end

          def log_output_using_parameters(parameters)
            logger&.debug("Outputting using parameters: #{parameters}...")
          end

          def log_output_complete
            logger&.info('Output complete.')
          end

          def output_command(opts = {})
            instantiate_command(RubyTerraform::Commands::Output, opts)
          end

          def output_parameters(parameters)
            with_output_state_file_parameters(
              with_output_standard_parameters(parameters)
            )
          end

          def with_output_standard_parameters(parameters)
            configuration_directory = parameters[:configuration_directory]

            parameters
              .except(:configuration_directory)
              .merge(
                chdir: configuration_directory
              )
          end

          def with_output_state_file_parameters(parameters)
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
