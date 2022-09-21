# frozen_string_literal: true

require_relative './base'
require_relative '../configuration/var_captor'

module RSpec
  module Terraform
    module Helpers
      class Var < Base
        def execute(overrides = {}, &block)
          parameters = with_configuration_provider_parameters(overrides)
          parameters = with_resolved_vars(parameters, &block)

          parameters[:vars][parameters[:name].to_sym]
        end
      end
    end
  end
end
