# frozen_string_literal: true

require 'ruby_terraform'

module RSpec
  module Terraform
    module Configuration
      module Providers
        class InMemory
          attr_reader(:configuration)

          def initialize(configuration = {})
            @configuration = configuration
          end

          def resolve(overrides = {})
            left_vars = configuration[:vars] || {}
            right_vars = overrides[:vars] || {}
            vars = left_vars.merge(right_vars)

            top_level_merge = configuration.merge(overrides)

            if left_vars == {} && right_vars == {}
              top_level_merge
            else
              top_level_merge.merge(vars: vars)
            end
          end
        end
      end
    end
  end
end
