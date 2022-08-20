# frozen_string_literal: true

require_relative 'configuration/providers'
require_relative 'configuration/merger'
require_relative 'configuration/var_captor'

module RSpec
  module Terraform
    module Configuration
      class << self
        def identity_provider
          Providers::Identity.new
        end

        def in_memory_provider(overrides)
          Providers::InMemory.new(overrides)
        end
      end
    end
  end
end
