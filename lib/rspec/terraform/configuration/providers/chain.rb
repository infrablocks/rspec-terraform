# frozen_string_literal: true

require 'ruby_terraform'

require_relative './base'

module RSpec
  module Terraform
    module Configuration
      module Providers
        class Chain < Base
          attr_reader(:providers)

          def initialize(opts = {})
            super()
            @providers = opts[:providers] || []
          end

          def resolve(overrides = {})
            providers.reduce(overrides) do |acc, provider|
              provider.resolve(acc)
            end
          end

          def reset
            providers.each { |provider| provider.reset }
          end
        end
      end
    end
  end
end
