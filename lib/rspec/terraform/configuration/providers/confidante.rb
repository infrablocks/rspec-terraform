# frozen_string_literal: true

require 'confidante'
require 'ruby_terraform'

require_relative 'base'
require_relative '../merger'

module RSpec
  module Terraform
    module Configuration
      module Providers
        class Confidante < Base
          attr_reader(
            :parameters,
            :scope_selector,
            :overrides_selector,
            :configuration,
            :merger
          )

          def initialize(opts = {})
            super()
            @parameters = opts[:parameters] || []
            @scope_selector = opts[:scope_selector] || ->(o) { o }
            @overrides_selector = opts[:overrides_selector] || ->(o) { o }
            @configuration = ::Confidante.configuration
            @merger = opts[:merger] || Merger.new
          end

          def resolve(overrides = {})
            resolved_configuration =
              configuration
                .for_scope(scope_selector.call(overrides))
                .for_overrides(overrides_selector.call(overrides))
            result = parameters.inject({}) do |acc, parameter|
              value = resolved_configuration.send(parameter)
              value.nil? ? acc : acc.merge(parameter => value)
            end
            merger.merge(result, overrides)
          end
        end
      end
    end
  end
end
