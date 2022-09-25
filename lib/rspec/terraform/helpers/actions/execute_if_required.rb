# frozen_string_literal: true

module RSpec
  module Terraform
    module Helpers
      module Actions
        module ExecuteIfRequired
          def execute_if_required(parameters, &block)
            only_if = parameters[:only_if]
            only_if_args = only_if ? [parameters].slice(0, only_if.arity) : []
            should_execute = only_if ? only_if.call(*only_if_args) : true

            block.call if should_execute
          end
        end
      end
    end
  end
end
