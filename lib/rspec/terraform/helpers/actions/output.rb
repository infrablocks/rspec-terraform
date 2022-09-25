# frozen_string_literal: true

require 'ruby_terraform'
require 'stringio'

require_relative './command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Output
          include CommandInstantiation

          def output(parameters)
            stdout = StringIO.new
            output_command(stdout: stdout)
              .execute(output_parameters(parameters))
            stdout.string
          end

          private

          def output_command(opts = {})
            instantiate_command(RubyTerraform::Commands::Output, opts)
          end

          def output_parameters(parameters)
            with_output_state_file_parameters(
              with_output_standard_parameters(parameters)
            )
          end

          def with_output_standard_parameters(parameters)
            parameters.merge(
              chdir: parameters[:configuration_directory]
            )
          end

          def with_output_state_file_parameters(parameters)
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
