# frozen_string_literal: true

require_relative '../configuration/var_captor'

module RSpec
  module Terraform
    module Helpers
      module Parameters
        def resolve_parameters(overrides, &)
          parameters = with_configuration_provider_parameters(overrides)
          parameters = with_resolved_vars(parameters, &)
          with_mandatory_parameters(parameters)
        end

        def with_configuration_provider_parameters(parameters)
          configuration_provider.resolve(parameters)
        end

        def with_resolved_vars(parameters, &block)
          return parameters unless block_given?

          var_captor = Configuration::VarCaptor.new(parameters[:vars] || {})
          block.call(var_captor)
          parameters.merge(vars: var_captor.to_h)
        end

        def with_mandatory_parameters(parameters)
          parameters.merge(mandatory_parameters)
        end
      end
    end
  end
end
