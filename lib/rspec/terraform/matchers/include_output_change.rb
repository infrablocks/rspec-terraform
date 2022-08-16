# frozen_string_literal: true

module RSpec
  module Terraform
    module Matchers
      class IncludeOutputChange
        attr_reader :definition

        def initialize(definition)
          @definition = definition
        end

        def matches?(plan)
          !definition_matches(plan).empty?
        end

        def with_value(_)
          self
        end

        private

        def definition_matches(plan)
          plan.output_changes_matching(definition)
        end
      end
    end
  end
end
