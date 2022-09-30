# frozen_string_literal: true

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Validate
          def validate(parameters)
            required = required_parameters(execution_mode)

            log_validate_starting(required)
            log_validate_using_parameters(parameters)

            missing = determine_missing(parameters, required)

            handle_result(missing)
          end

          private

          def determine_missing(parameters, required)
            required.filter { |parameter| parameters[parameter].nil? }
          end

          def handle_result(missing)
            if missing.empty?
              log_validate_successful
            else
              log_validate_failed(missing)
              raise_missing_parameters(missing)
            end
          end

          def log_validate_starting(required)
            logger&.info(
              "Validating required parameters: #{required} present..."
            )
          end

          def log_validate_using_parameters(parameters)
            logger&.debug("Validating parameters: #{parameters}...")
          end

          def log_validate_successful
            logger&.info('Validate successful.')
          end

          def log_validate_failed(missing)
            logger&.error("Validate failed. Parameters: #{missing} missing.")
          end

          def raise_missing_parameters(parameters)
            parameters = parameters.collect { |parameter| "`:#{parameter}`" }
            if parameters.count == 1
              raise StandardError,
                    "Required parameter: #{parameters[0]} missing."
            else
              parameters =
                "#{parameters[..-2].join(', ')} and #{parameters[-1]}"
              raise StandardError,
                    "Required parameters: #{parameters} missing."
            end
          end
        end
      end
    end
  end
end
