# frozen_string_literal: true

require_relative '../configuration/var_captor'

module RSpec
  module Terraform
    module Helpers
      class Var
        attr_reader(:overrides, :configuration_provider)

        def initialize(overrides = {}, configuration_provider = nil)
          @overrides = overrides
          @configuration_provider =
            configuration_provider || Configuration.identity_provider
        end

        def execute(&block)
          parameters = with_configuration_provider_parameters(overrides)
          parameters = with_resolved_vars(parameters, &block)

          parameters[:vars][parameters[:name].to_sym]
        end

        private

        def with_configuration_provider_parameters(parameters)
          configuration_provider.resolve(parameters)
        end

        def with_resolved_vars(parameters, &block)
          return parameters unless block_given?

          var_captor = Configuration::VarCaptor.new(parameters[:vars] || {})
          block.call(var_captor)
          parameters.merge(vars: var_captor.to_h)
        end
      end
    end
  end
end
