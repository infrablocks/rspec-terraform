# frozen_string_literal: true

module RSpec
  module Terraform
    module Helpers
      module Actions
        module Validate
          def validate(parameters)
            missing_parameters =
              required_parameters(execution_mode)
                .filter { |parameter| parameters[parameter].nil? }

            return if missing_parameters.empty?

            raise_missing_parameters(missing_parameters)
          end

          private

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
