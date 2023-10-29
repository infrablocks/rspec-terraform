# frozen_string_literal: true

require 'ruby_terraform'
require 'securerandom'

require_relative 'command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Plan
          include CommandInstantiation

          def plan(parameters)
            parameters = plan_parameters(parameters)

            log_plan_starting(parameters)
            log_plan_using_parameters(parameters)

            plan_command.execute(parameters)

            log_plan_complete

            parameters[:out]
          end

          private

          def log_plan_starting(parameters)
            logger&.info(
              'Planning for configuration in directory: ' \
              "'#{parameters[:chdir]}'..."
            )
          end

          def log_plan_using_parameters(parameters)
            logger&.debug("Planning using parameters: #{parameters}...")
          end

          def log_plan_complete
            logger&.info('Plan complete.')
          end

          def plan_command
            instantiate_command(RubyTerraform::Commands::Plan)
          end

          def plan_parameters(parameters)
            with_plan_state_file_parameters(
              with_plan_standard_parameters(parameters)
            )
          end

          def with_plan_standard_parameters(parameters)
            configuration_directory = parameters[:configuration_directory]
            plan_file_name = resolve_plan_file_name(parameters)

            parameters
              .except(:configuration_directory, :plan_file_name)
              .merge(
                chdir: configuration_directory,
                out: plan_file_name,
                input: false
              )
          end

          def resolve_plan_file_name(parameters)
            parameters[:plan_file_name] || random_plan_file_name
          end

          def random_plan_file_name
            "#{SecureRandom.hex[0, 10]}.tfplan"
          end

          def with_plan_state_file_parameters(parameters)
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
