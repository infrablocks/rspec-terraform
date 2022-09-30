# frozen_string_literal: true

require 'ruby_terraform'

require_relative './base'
require_relative './actions'

module RSpec
  module Terraform
    module Helpers
      class Apply < Base
        include Actions::ExecuteIfRequired
        include Actions::Validate
        include Actions::Clean
        include Actions::Init
        include Actions::Apply

        def execute(overrides = {}, &block)
          parameters = resolve_parameters(overrides, &block)

          execute_if_required(:apply, parameters) do
            validate(parameters)
            clean(parameters)
            init(parameters)
            apply(parameters)
          end
        end

        private

        def mandatory_parameters
          {
            input: false,
            auto_approve: true
          }
        end

        def required_parameters(execution_mode)
          {
            in_place: [:configuration_directory],
            isolated: %i[source_directory configuration_directory]
          }[execution_mode] || []
        end
      end
    end
  end
end
