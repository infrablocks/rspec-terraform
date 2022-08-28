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

        def in_memory_provider(opts = {})
          Providers::InMemory.new(opts)
        end

        def confidante_provider(opts = {})
          Providers::Confidante.new(opts)
        end

        def seed_provider(opts = {})
          Providers::Seed.new(opts)
        end

        def chain_provider(opts = {})
          Providers::Chain.new(opts)
        end
      end
    end
  end
end
