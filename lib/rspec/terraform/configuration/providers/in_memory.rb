# frozen_string_literal: true

require 'ruby_terraform'
require_relative '../merger'

module RSpec
  module Terraform
    module Configuration
      module Providers
        class InMemory
          attr_reader(:configuration)

          def initialize(configuration = {})
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
