# frozen_string_literal: true

require 'ruby_terraform'

require_relative 'base'

module RSpec
  module Terraform
    module Configuration
      module Providers
        class Identity < Base
          def resolve(overrides = {})
            overrides
          end
        end
      end
    end
  end
end
