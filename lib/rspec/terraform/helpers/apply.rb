# frozen_string_literal: true

require 'ruby_terraform'

module RSpec
  module Terraform
    module Helpers
      class Apply
        attr_reader(:overrides, :configuration_provider)

        def initialize(overrides = {}, configuration_provider = nil)
          @overrides = overrides
          @configuration_provider =
            configuration_provider || Configuration.identity_provider
        end

        def execute
          parameters = configuration_provider.resolve(overrides)
          parameters = parameters.merge(
            input: false,
            auto_approve: true
          )

          do_apply(parameters)
        end

        private

        def do_apply(parameters)
          RubyTerraform.apply(
            chdir: parameters[:configuration_directory],
            state: parameters[:state_file],
            vars: parameters[:vars],
            input: parameters[:input],
            auto_approve: parameters[:auto_approve]
          )
        end
      end
    end
  end
end
