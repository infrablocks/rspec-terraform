# frozen_string_literal: true

require 'rspec/core'
require 'rspec/matchers'
require 'rspec/matchers/built_in/eq'
require 'rspec/matchers/built_in/count_expectation'

require 'ruby_terraform/models/path'
require 'ruby_terraform/models/path_set'

module RSpec
  module Terraform
    module Matchers
      # rubocop:disable Metrics/ClassLength
      class IncludeResourceChange
        include RSpec::Matchers::BuiltIn::CountExpectation

        attr_reader :definition, :attributes, :plan

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
          path = RubyTerraform::Models::Path.new(path)
          value = maybe_box_value(value)
          @attributes << { stage:, path:, value: }
          self
        end

        def failure_message
          "\nexpected: #{positive_expected_line}" \
            "\n     got: #{positive_got_line}"
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

        def maybe_box_value(value)
          if value.respond_to?(:matches?)
            value
          else
            RubyTerraform::Models::Objects.box(value)
          end
        end

        def attribute_matcher(attribute)
          expected = attribute[:value]
          return expected if expected.respond_to?(:matches?)

          RSpec::Matchers::BuiltIn::Eq.new(expected)
        end

        def attribute_value(object, attribute)
          expected = attribute[:value]
          actual = attribute[:path].read(object)
          return actual&.unbox if expected.respond_to?(:matches?)

          actual
        end

        def positive_expected_line
          maybe_with_expected_attributes(
            maybe_with_definition(
              positive_plan_line
            )
          )
        end

        def positive_plan_line
          cardinality = cardinality_fragment
          plurality = expected_count.nil? || expected_count == 1 ? '' : 's'

          "a plan including #{cardinality} resource change#{plurality}"
        end

        def maybe_with_definition(expected_line)
          unless @definition.empty?
            expected_line =
              "#{expected_line} matching definition:\n#{definition_lines}"
          end
          expected_line
        end

        def maybe_with_expected_attributes(expected_line)
          unless @attributes.empty?
            expected_line =
              "#{expected_line}\n          with attribute values after " \
              "the resource change is applied of:\n#{expected_attribute_lines}"
          end
          expected_line
        end

        # rubocop:disable Metrics/MethodLength
        def positive_got_line
          if plan.resource_changes.empty?
            'a plan including no resource changes.'
          else
            count = attribute_matches(plan).count
            amount = count.zero? ? 'no' : cardinality_amount(count)
            plurality = count == 1 ? '' : 's'
            got_line =
              "a plan including #{amount} matching " \
              "resource change#{plurality}."

            with_available_resource_changes(
              maybe_with_relevant_resource_changes(got_line)
            )
          end
        end

        def with_available_resource_changes(got_line)
          "#{got_line}\n          available resource changes are:" \
            "\n#{available_resource_change_lines}"
        end

        def maybe_with_relevant_resource_changes(got_line)
          unless attributes.empty?
            got_line =
              "#{got_line}\n          relevant resource changes are:" \
              "\n#{relevant_resource_change_lines}"
          end
          got_line
        end

        # rubocop:enable Metrics/MethodLength

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
          indent = '            '
          definition
            .collect { |k, v| "#{indent}#{k} = #{v.inspect}" }
            .join("\n")
        end

        def expected_attribute_lines
          paths = attributes.collect { |attribute| attribute[:path] }
          path_set = RubyTerraform::Models::PathSet.new(paths)
          values = attributes.collect do |attribute|
            with_matcher_renderable(attribute[:value])
          end
          object = RubyTerraform::Models::Objects.object(path_set, values)
          object.render(level: 6, bare: true)
        end

        def relevant_resource_change_lines
          relevant_lines = definition_matches(plan).collect do |rc|
            address = rc.address
            actions = rc.change.actions.join(', ')
            attributes = rc.change.after_object
            attribute_lines = attributes.render(level: 8, bare: true)

            "            - #{address} (#{actions})\n#{attribute_lines}"
          end
          relevant_lines.join("\n")
        end

        def available_resource_change_lines
          available_lines = plan.resource_changes.collect do |rc|
            address = rc.address
            actions = rc.change.actions.join(', ')
            "            - #{address} (#{actions})"
          end
          available_lines.join("\n")
        end

        def with_matcher_renderable(value)
          return value if value.respond_to?(:render)

          value.define_singleton_method(:render) do |_|
            "a value satisfying: #{value.description}"
          end

          value
        end
      end

      # rubocop:enable Metrics/ClassLength
    end
  end
end
