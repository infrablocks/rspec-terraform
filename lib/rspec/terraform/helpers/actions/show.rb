# frozen_string_literal: true

require 'ruby_terraform'
require 'stringio'

require_relative './command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Show
          include CommandInstantiation

          def show(parameters, plan_file)
            parameters = show_parameters(parameters, plan_file)

            log_show_starting(parameters, plan_file)
            log_show_using_parameters(parameters)

            stdout = StringIO.new
            show_command(stdout: stdout)
              .execute(parameters)

            log_show_complete

            stdout.string
          end

          private

          def log_show_starting(parameters, plan_file)
            logger&.info(
              "Showing file: '#{plan_file}' in configuration directory: " \
              "'#{parameters[:chdir]}'..."
            )
          end

          def log_show_using_parameters(parameters)
            logger&.debug("Showing using parameters: #{parameters}...")
          end

          def log_show_complete
            logger&.info('Show complete.')
          end

          def show_command(opts = {})
            instantiate_command(RubyTerraform::Commands::Show, opts)
          end

          def show_parameters(parameters, plan_file)
            with_show_plan_file_parameters(
              with_show_standard_parameters(parameters),
              plan_file
            )
          end

          def with_show_standard_parameters(parameters)
            configuration_directory = parameters[:configuration_directory]

            parameters
              .except(:configuration_directory)
              .merge(
                chdir: configuration_directory,
                no_color: true,
                json: true
              )
          end

          def with_show_plan_file_parameters(parameters, plan_file)
            parameters.merge(
              path: plan_file
            )
          end
        end
      end
    end
  end
end
