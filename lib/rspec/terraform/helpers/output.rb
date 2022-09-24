# frozen_string_literal: true

require 'ruby_terraform'

require_relative './base'

module RSpec
  module Terraform
    module Helpers
      class Output < Base
        def execute(overrides = {})
          parameters = resolve_parameters(overrides)

          validate(parameters)
          clean(parameters)
          init(parameters)
          output_value = output(parameters)

          parse(output_value)
        end

        private

        def mandatory_parameters
          {
            json: true
          }
        end

        def required_parameters(execution_mode)
          {
            in_place: %i[name configuration_directory],
            isolated: %i[name source_directory configuration_directory]
          }[execution_mode] || []
        end

        def parse(output_value)
          JSON.parse(output_value, symbolize_names: true)
        end
      end
    end
  end
end
