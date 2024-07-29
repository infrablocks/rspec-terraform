# frozen_string_literal: true

require 'ruby_terraform'

require_relative 'base'
require_relative 'actions'

module RSpec
  module Terraform
    module Helpers
      class Destroy < Base
        include Actions::ExecuteIfRequired
        include Actions::Validate
        include Actions::Clean
        include Actions::Init
        include Actions::Destroy

        def execute(overrides = {}, &)
          parameters = resolve_parameters(overrides, &)

          execute_if_required(:destroy, parameters) do
            validate(parameters)
            clean(parameters)
            init(parameters)
            destroy(parameters)
          end
        end

        private

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
