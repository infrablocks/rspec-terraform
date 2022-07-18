# frozen_string_literal: true

require 'rspec/core'
require 'rspec/matchers'
require 'rspec/matchers/built_in/eq'
require 'rspec/matchers/built_in/count_expectation'

module RSpec
  module Terraform
    module Matchers
      # rubocop:disable Metrics/ClassLength
      class IncludeResourceChange
        include RSpec::Matchers::BuiltIn::CountExpectation

        attr_reader :definition, :plan

        def initialize(definition = {})
          @definition = definition
          @attributes = []
        end

        def matches?(plan)
          @plan = plan
          matches = attribute_matches(plan)

          match_count = matches.count
          if has_expected_count?
            expected_count_matches?(match_count)
          else
            match_count.positive?
          end
        end

        def with_attribute_value(*args)
          stage, path, value = args.count == 3 ? args : [:after, *args]
          path = [path] if path.is_a?(Symbol)
          @attributes << { stage: stage, path: path, value: value }
          self
        end

        def failure_message
          "\nexpected: #{positive_expected_line}" \
            "\n     got: #{positive_got_line}" \
            "\n          available resource changes are:" \
            "\n#{resource_change_lines}"
        end

        def failure_message_when_negated
          "\nexpected: a plan including no resource changes" \
            "\n     got: a plan including at least one resource change"
        end

        private

        def definition_matches(plan)
          plan.resource_changes_matching(definition)
        end

        def attribute_matches(plan)
          definition_matches(plan).filter do |resource_change|
            change = resource_change.change
            after = change.after_object
            @attributes.all? do |attribute|
              matcher = attribute_matcher(attribute)
              value = attribute_value(after, attribute)
              matcher.matches?(value)
            end
          end
        end

        def attribute_matcher(attribute)
          expected = attribute[:value]
          return expected if expected.respond_to?(:matches?)

          RSpec::Matchers::BuiltIn::Eq.new(
            RubyTerraform::Models::Objects.box(expected)
          )
        end

        def attribute_value(object, attribute)
          expected = attribute[:value]
          actual = object.dig(*attribute[:path])
          return actual&.unbox if expected.respond_to?(:matches?)

          actual
        end

        def positive_expected_line
          cardinality = cardinality_fragment
          plurality = expected_count.nil? || expected_count == 1 ? '' : 's'
          expected_line =
            "a plan including #{cardinality} resource change#{plurality}"

          unless @definition.empty?
            expected_line =
              "#{expected_line} matching definition:\n#{definition_lines}"
          end

          expected_line
        end

        def positive_got_line
          if plan.resource_changes.empty?
            'a plan including no resource changes.'
          else
            count = attribute_matches(plan).count
            amount = count.zero? ? 'no' : cardinality_amount(count)
            plurality = count == 1 ? '' : 's'
            "a plan including #{amount} matching resource change#{plurality}."
          end
        end

        def cardinality_fragment
          qualifier = cardinality_qualifier
          amount = cardinality_amount(expected_count)
          "#{qualifier} #{amount}"
        end

        def cardinality_qualifier
          case count_expectation_type
          when :<= then 'at most'
          when nil, :>= then 'at least'
          when :== then 'exactly'
          when :<=> then 'between'
          end
        end

        def cardinality_amount(count)
          case count
          when Range then "#{count.first} and #{count.last}"
          when nil, 1 then 'one'
          when 2 then 'two'
          when 3 then 'three'
          else count.to_s
          end
        end

        def definition_lines
          definition
            .collect { |k, v| "            #{k}: #{v}" }
            .join("\n")
        end

        def resource_change_lines
          plan.resource_changes
            .collect do |rc|
              address = rc.address
              actions = rc.change.actions.join(', ')
              "            - #{address} (#{actions})"
            end
            .join("\n")
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
