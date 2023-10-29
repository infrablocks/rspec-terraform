# frozen_string_literal: true

require 'ruby_terraform'

require_relative 'base'
require_relative '../merger'

module RSpec
  module Terraform
    module Configuration
      module Providers
        class InMemory < Base
          attr_reader(:configuration)

          def initialize(configuration = {})
            super()
            @configuration = configuration
            @merger = Merger.new
          end

          def resolve(overrides = {})
            @merger.merge(configuration, overrides)
          end
        end
      end
    end
  end
end
