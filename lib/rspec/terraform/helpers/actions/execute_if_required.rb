# frozen_string_literal: true

module RSpec
  module Terraform
    module Helpers
      module Actions
        module ExecuteIfRequired
          def execute_if_required(name, parameters, &block)
            log_execute_if_required_starting(name)

            if should_execute(parameters)
              log_execute_if_required_continuing
              block.call
            else
              log_execute_if_required_skipping
            end
          end

          private

          def should_execute(parameters)
            only_if = parameters[:only_if]
            only_if_args = only_if ? [parameters].slice(0, only_if.arity) : []
            only_if ? only_if.call(*only_if_args) : true
          end

          def log_execute_if_required_starting(name)
            logger&.info("Checking if execution of #{name} required...")
          end

          def log_execute_if_required_continuing
            logger&.info('Execution required. Continuing...')
          end

          def log_execute_if_required_skipping
            logger&.info('Execution not required. Skipping...')
          end
        end
      end
    end
  end
end
