# frozen_string_literal: true

require 'ruby_terraform'

module RSpec
  module Terraform
    module Configuration
      module Providers
        class Identity
          def resolve(overrides)
            overrides
          end
        end
      end
    end
  end
end
