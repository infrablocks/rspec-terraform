# frozen_string_literal: true

require_relative './matchers/include_resource_change'

module RSpec
  module Terraform
    module Matchers
      def include_resource_change(definition = {})
        IncludeResourceChange.new(definition)
      end

      def include_resource_creation(definition = {})
        include_resource_change(definition.merge(create?: true))
      end

      def include_resource_read(definition = {})
        include_resource_change(definition.merge(read?: true))
      end

      def include_resource_update(definition = {})
        include_resource_change(definition.merge(update?: true))
      end

      def include_resource_replacement(definition = {})
        include_resource_change(definition.merge(replace?: true))
      end

      def include_resource_deletion(definition = {})
        include_resource_change(definition.merge(delete?: true))
      end
    end
  end
end
