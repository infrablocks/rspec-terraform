# frozen_string_literal: true

require 'ruby_terraform'
require 'securerandom'

require_relative './command_instantiation'

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Plan
          include CommandInstantiation

          def plan(parameters)
            plan_parameters = plan_parameters(parameters)
            plan_command.execute(plan_parameters)
            plan_parameters[:out]
          end

          private

          def plan_command
            instantiate_command(RubyTerraform::Commands::Plan)
          end

          def plan_parameters(parameters)
            with_plan_state_file_parameters(
              with_plan_standard_parameters(parameters)
            )
          end

          def with_plan_standard_parameters(parameters)
            parameters.merge(
              chdir: parameters[:configuration_directory],
              out: parameters[:plan_file_name] ||
                "#{SecureRandom.hex[0, 10]}.tfplan",
              input: false
            )
          end

          def with_plan_state_file_parameters(parameters)
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
