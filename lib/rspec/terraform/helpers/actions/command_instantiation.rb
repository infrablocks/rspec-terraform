# frozen_string_literal: true

module RSpec
  module Terraform
    module Helpers
      module Actions
        module CommandInstantiation
          def instantiate_command(klass, opts = {})
            klass.new(command_options.merge(opts))
          end
        end
      end
    end
  end
end
