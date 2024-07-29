# frozen_string_literal: true

require_relative 'base'
require_relative '../configuration/var_captor'

module RSpec
  module Terraform
    module Helpers
      class Var < Base
        def execute(overrides = {}, &)
          parameters = resolve_parameters(overrides, &)

          parameters[:vars][parameters[:name].to_sym]
        end
      end
    end
  end
end
