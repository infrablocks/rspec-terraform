# frozen_string_literal: true

module RSpec
  module Terraform
    module Matchers
      class IncludeOutputChange
        attr_reader :definition, :value

        def initialize(definition)
          @definition = definition
          @value = nil
        end

        def matches?(plan)
          !value_matches(plan).empty?
        end

        def with_value(value)
          @value = maybe_box_value(value)
          self
        end

        private

        def definition_matches(plan)
          plan.output_changes_matching(definition)
        end

        def value_matches(plan)
          matches = definition_matches(plan)
          return matches unless value

          expected = value_matcher(value)

          matches.filter do |output_change|
            change = output_change.change
            after = change.after_object
            actual = resolved_value(value, after)

            expected&.matches?(actual)
          end
        end

        def maybe_box_value(value)
          if value.respond_to?(:matches?)
            value
          else
            RubyTerraform::Models::Objects.box(value)
          end
        end

        def value_matcher(expected)
          return expected if expected.respond_to?(:matches?)

          RSpec::Matchers::BuiltIn::Eq.new(expected)
        end

        def resolved_value(expected, actual)
          return actual&.unbox if expected.respond_to?(:matches?)

          actual
        end
      end
    end
  end
end
