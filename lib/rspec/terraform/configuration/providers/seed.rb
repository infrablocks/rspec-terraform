# frozen_string_literal: true

require 'ruby_terraform'
require 'securerandom'

require_relative 'base'

module RSpec
  module Terraform
    module Configuration
      module Providers
        class Seed < Base
          attr_reader(:generator, :merger)

          def initialize(opts = {})
            super()
            @generator =
              opts[:generator] || -> { SecureRandom.alphanumeric(10) }
            @merger = opts[:merger] || Merger.new
          end

          def resolve(overrides = {})
            merger.merge({ seed: }, overrides)
          end

          def reset
            @seed = nil
          end

          private

          def seed
            @seed ||= generator.call
          end
        end
      end
    end
  end
end
