# frozen_string_literal: true

require 'ruby_terraform'
require 'securerandom'
require 'stringio'

require_relative './base'

module RSpec
  module Terraform
    module Helpers
      class Plan < Base
        def execute(overrides = {}, &block)
          parameters = resolve_parameters(overrides, &block)

          validate(parameters)
          clean(parameters)
          init(parameters)
          plan_file = plan(parameters)
          plan_contents = show(parameters, plan_file)
          remove(parameters, plan_file)
          parse(plan_contents)
        end

        private

        def required_parameters(execution_mode)
          {
            in_place: [:configuration_directory],
            isolated: %i[source_directory configuration_directory]
          }[execution_mode] || []
        end

        def parse(plan_contents)
          RubyTerraform::Models::Plan.new(
            JSON.parse(plan_contents, symbolize_names: true)
          )
        end
      end
    end
  end
end
